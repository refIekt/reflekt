require 'set'
require 'erb'
require 'rowdb'
require 'Control'
require 'Execution'
require 'Reflection'
require 'Ruler'
require 'ShadowStack'

################################################################################
# REFLEKT
#
# An Execution is created each time a method is called.
# Multiple Refections are created per Execution.
# These Reflections execute on a ShadowStack on cloned objects.
# Then flow is returned to the original method and normal execution continues.
#
# Usage:
#
#   class ExampleClass
#     prepend Reflekt
################################################################################

module Reflekt

  # The amount of reflections to create per method call.
  @@reflekt_reflect_amount = 2

  # Limit the amount of reflections that can be created per instance method.
  # A method called thousands of times doesn't need that many reflections.
  @@reflection_limit = 10

  def initialize(*args)

    @reflection_counts = {}

    # Get instance methods.
    # TODO: Include parent methods like "Array.include?".
    self.class.instance_methods(false).each do |method|

      # Don't process skipped methods.
      next if self.class.reflekt_skipped?(method)

      @reflection_counts[method] = 0

      # When method called in flow.
      self.define_singleton_method(method) do |*args|

        # Don't reflect when limit reached.
        unless @reflection_counts[method] >= @@reflection_limit

          # Get current execution.
          execution = @@reflekt_stack.peek()

          # When stack empty or past execution done reflecting.
          if execution.nil? || execution.has_finished_reflecting?

            # Create execution.
            execution = Execution.new(self, @@reflekt_reflect_amount)
            @@reflekt_stack.push(execution)

          end

          # Get ruler.
          # The method's ruler will not exist the first time the db generated.
          if @@reflekt_rules.key? execution.caller_class.to_s.to_sym
            ruler = @@reflekt_rules[execution.caller_class.to_s.to_sym][method.to_s]
          else
            ruler = nil
          end

          # Reflect.
          # The first method call in the Execution creates a Reflection.
          # Subsequent method calls are shadow executions on cloned objects.
          if execution.has_empty_reflections? && !execution.is_reflecting?
            execution.is_reflecting = true

            class_name = execution.caller_class.to_s
            method_name = method.to_s

            # Create control.
            control = Control.new(execution, method, ruler)
            execution.control = control

            # Execute control.
            control.reflect(*args)

            # Save control.
            @@reflekt_db.get("#{class_name}.#{method_name}.controls").push(control.result())

            # Multiple reflections per execution.
            execution.reflections.each_with_index do |value, index|

              # Create reflection.
              reflection = Reflection.new(execution, method, ruler)
              execution.reflections[index] = reflection

              # Execute reflection.
              reflection.reflect(*args)
              @reflection_counts[method] = @reflection_counts[method] + 1

              # Save reflection.
              @@reflekt_db.get("#{class_name}.#{method_name}.reflections").push(reflection.result())

            end

            # Save results.
            @@reflekt_db.write()

            # Render results.
            reflekt_render()

            execution.is_reflecting = false
          end

        end

        # Continue execution / shadow execution.
        super *args

      end

    end

    # Continue initialization.
    super

  end

  ##
  # Render results.
  ##
  def reflekt_render()

    # Get JSON.
    @@reflekt_json = File.read("#{@@reflekt_output_path}/db.json")

    # Save HTML.
    template = File.read("#{@@reflekt_path}/web/template.html.erb")
    rendered = ERB.new(template).result(binding)
    File.open("#{@@reflekt_output_path}/index.html", 'w+') do |f|
      f.write rendered
    end

    # Add JS.
    javascript = File.read("#{@@reflekt_path}/web/script.js")
    File.open("#{@@reflekt_output_path}/script.js", 'w+') do |f|
      f.write javascript
    end

    # Add CSS.
    stylesheet = File.read("#{@@reflekt_path}/web/style.css")
    File.open("#{@@reflekt_output_path}/style.css", 'w+') do |f|
      f.write stylesheet
    end

  end

  private

  def self.prepended(base)
    # Prepend class methods to the instance's singleton class.
    base.singleton_class.prepend(SingletonClassMethods)

    @@reflekt_setup ||= reflekt_setup_class
  end

  # Setup class.
  def self.reflekt_setup_class()

    # Receive configuration.
    $ENV ||= {}
    $ENV[:reflekt] ||= $ENV[:reflekt] = {}

    # Set configuration.
    @@reflekt_path = File.dirname(File.realpath(__FILE__))

    # Build reflections directory.
    if $ENV[:reflekt][:output_path]
      @@reflekt_output_path = File.join($ENV[:reflekt][:output_path], 'reflections')
    # Build reflections directory in current execution path.
    else
      @@reflekt_output_path = File.join(Dir.pwd, 'reflections')
    end
    # Create reflections directory.
    unless Dir.exist? @@reflekt_output_path
      Dir.mkdir(@@reflekt_output_path)
    end

    # Create database.
    @@reflekt_db = Rowdb.new(@@reflekt_output_path + '/db.json')
    @@reflekt_db.defaults({ :reflekt => { :api_version => 1 }})

    # Create shadow execution stack.
    @@reflekt_stack = ShadowStack.new()

    # Define rules.
    # TODO: Fix Rowdb.get(path) not returning data at path after Rowdb.push()?
    @@reflekt_rules = {}
    db = @@reflekt_db.value()
    db.each do |class_name, class_values|
      @@reflekt_rules[class_name] = {}
      class_values.each do |method_name, method_values|
        next if method_values.nil?
        next unless method_values.class == Hash
        if method_values.key? "controls"

          ruler = Ruler.new()
          ruler.load(method_values['controls'])
          ruler.train()

          @@reflekt_rules[class_name][method_name] = ruler
        end
      end
    end

    return true
  end

  module SingletonClassMethods

    @@reflekt_skipped_methods = Set.new

    ##
    # Skip a method.
    #
    # @param method - A symbol representing the method name.
    ##
    def reflekt_skip(method)
      @@reflekt_skipped_methods.add(method)
    end

    def reflekt_skipped?(method)
      return true if @@reflekt_skipped_methods.include?(method)
      false
    end

    def reflekt_limit(amount)
      @@reflection_limit = amount
    end

  end

end
