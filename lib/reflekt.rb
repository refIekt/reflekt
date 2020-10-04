require 'set'
require 'erb'
require 'rowdb'
require 'Accessor'
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
        unless @reflection_counts[method] >= @@reflekt.reflection_limit

          # Get current execution.
          execution = @@reflekt.stack.peek()

          # When stack empty or past execution done reflecting.
          if execution.nil? || execution.has_finished_reflecting?

            # Create execution.
            execution = Execution.new(self, @@reflekt.reflect_amount)
            @@reflekt.stack.push(execution)

          end

          # Get ruler.
          # The method's ruler will not exist the first time the db generated.
          if @@reflekt.rules.key? execution.caller_class.to_s.to_sym
            ruler = @@reflekt.rules[execution.caller_class.to_s.to_sym][method.to_s]
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
            @@reflekt.db.get("#{class_name}.#{method_name}.controls").push(control.result())

            # Multiple reflections per execution.
            execution.reflections.each_with_index do |value, index|

              # Create reflection.
              reflection = Reflection.new(execution, method, ruler)
              execution.reflections[index] = reflection

              # Execute reflection.
              reflection.reflect(*args)
              @reflection_counts[method] = @reflection_counts[method] + 1

              # Save reflection.
              @@reflekt.db.get("#{class_name}.#{method_name}.reflections").push(reflection.result())

            end

            # Save results.
            @@reflekt.db.write()

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
    @@reflekt.json = File.read("#{@@reflekt.output_path}/db.json")

    # Save HTML.
    template = File.read("#{@@reflekt.path}/web/template.html.erb")
    rendered = ERB.new(template).result(binding)
    File.open("#{@@reflekt.output_path}/index.html", 'w+') do |f|
      f.write rendered
    end

    # Add JS.
    javascript = File.read("#{@@reflekt.path}/web/script.js")
    File.open("#{@@reflekt.output_path}/script.js", 'w+') do |f|
      f.write javascript
    end

    # Add CSS.
    stylesheet = File.read("#{@@reflekt.path}/web/style.css")
    File.open("#{@@reflekt.output_path}/style.css", 'w+') do |f|
      f.write stylesheet
    end

  end

  private

  def self.prepended(base)

    # Prepend class methods to the instance's singleton class.
    base.singleton_class.prepend(SingletonClassMethods)

    # Setup class.
    @@reflekt = Accessor.new()
    @@reflekt.setup ||= reflekt_setup_class

  end

  # Setup class.
  def self.reflekt_setup_class()

    # Receive configuration.
    $ENV ||= {}
    $ENV[:reflekt] ||= $ENV[:reflekt] = {}

    # Set configuration.
    @@reflekt.path = File.dirname(File.realpath(__FILE__))

    # Build reflections directory.
    if $ENV[:reflekt][:output_path]
      @@reflekt.output_path = File.join($ENV[:reflekt][:output_path], 'reflections')
    # Build reflections directory in current execution path.
    else
      @@reflekt.output_path = File.join(Dir.pwd, 'reflections')
    end
    # Create reflections directory.
    unless Dir.exist? @@reflekt.output_path
      Dir.mkdir(@@reflekt.output_path)
    end

    # Create database.
    @@reflekt.db = Rowdb.new(@@reflekt.output_path + '/db.json')
    @@reflekt.db.defaults({ :reflekt => { :api_version => 1 }})

    # Create shadow execution stack.
    @@reflekt.stack = ShadowStack.new()

    # Define rules.
    # TODO: Fix Rowdb.get(path) not returning data at path after Rowdb.push()?
    @@reflekt.rules = {}
    db = @@reflekt.db.value()
    db.each do |class_name, class_values|
      @@reflekt.rules[class_name] = {}
      class_values.each do |method_name, method_values|
        next if method_values.nil?
        next unless method_values.class == Hash
        if method_values.key? "controls"

          ruler = Ruler.new()
          ruler.load(method_values['controls'])
          ruler.train()

          @@reflekt.rules[class_name][method_name] = ruler
        end
      end
    end

    # The amount of reflections to create per method call.
    @@reflekt.reflect_amount = 2

    # Limit the amount of reflections that can be created per instance method.
    # A method called thousands of times doesn't need that many reflections.
    @@reflekt.reflection_limit = 10

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
      @@reflekt.reflection_limit = amount
    end

  end

end
