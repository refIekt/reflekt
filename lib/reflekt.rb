require 'set'
require 'erb'
require 'rowdb'
require 'Execution'
require 'Reflection'
require 'ShadowStack'

################################################################################
# REFLEKT
#
# An Execution is created each time a method is called.
# Multiple Refections are created per Execution.
# These Reflections run through their own execution stack on cloned objects.
# Then the flow is returned to the original method and Execution is moved on.
#
# Usage. Prepend to the class like so:
#
#   class ExampleClass
#     prepend Reflekt
################################################################################

module Reflekt

  @@reflekt_reflect_amount = 1
  @@reflected_count = 0

  def initialize(*args)

    @reflekt_processed = false
    @reflekt_clones = []

    # Limit the amount of reflections that can be created per instance.
    # A method called thousands of times doesn't need that many reflections.
    @reflection_limit = 5

    # Override methods.
    self.class.instance_methods(false).each do |method|
      self.define_singleton_method(method) do |*args|

        # Get current execution.
        execution = @@reflekt_stack.peek()
        # Create new execution when stack empty or past execution done reflecting.
        if execution.nil? || execution.has_finished_reflecting?
          execution = @@reflekt_stack.push(self, @@reflekt_reflect_amount)
        end

        p '-------------------'
        p execution.object_id
        p execution.object.class.to_s
        p method
        p execution.has_finished_reflecting?

        # Reflect.
        if execution.has_empty_reflections? && !self.class.reflekt_skipped?(method)
          if @@reflected_count < @reflection_limit

            # The first method call in the Execution starts the Reflection.
            # Subsequent method calls execute as normal on cloned objects.
            unless execution.is_reflecting?
              execution.is_reflecting = true

              # Create multiple reflections.
              execution.reflections.each do |reflection|

                reflection = Reflection.new(execution)
                reflection = reflection.reflect(method, *args)
                # TODO: reflection.result()

                class_name = execution.object.class.to_s
                method_name = method.to_s
                @@reflekt_db.get("#{class_name}.#{method_name}").push(reflection)

              end

              @@reflected_count = @@reflected_count + 1

              # Save results.
              @@reflekt_db.write()

              reflekt_render()

              #@@reflekt_stack.display
            end
          end

        end

        # Execute method.
        super *args

      end

    end

    # Continue initialization.
    super

  end

  def reflekt_render()

    # Render results.
    @@reflekt_json = File.read("#{@@reflekt_output_path}/db.json")
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

    # Create reflection tree.
    @@reflekt_stack = ShadowStack.new()

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
    @@reflekt_db.defaults({ :reflekt => { :api_version => 1 }}).write()

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
      @reflection_limit = amount
    end

  end

end
