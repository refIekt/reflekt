################################################################################
# REFLEKT - By Maedi Prichard.
#
# An Execution is created each time a method is called.
# Many Refections are created per Execution.
# Each Reflection executes on a ShadowStack on cloned data.
# Then flow is returned to the original method and normal execution continues.
#
# Usage:
#   class ExampleClass
#     prepend Reflekt
################################################################################

require 'set'
require 'erb'
require 'rowdb'
require 'Accessor'
require 'Control'
require 'Execution'
require 'Reflection'
require 'Renderer'
require 'Ruler'
require 'ShadowStack'

module Reflekt

  def initialize(*args)

    @reflekt_counts = {}

    # Get instance methods.
    # TODO: Include parent methods like "Array.include?".
    self.class.instance_methods(false).each do |method|

      # Don't process skipped methods.
      next if self.class.reflekt_skipped?(method)

      @reflekt_counts[method] = 0

      # When method called in flow.
      self.define_singleton_method(method) do |*args|

        # Don't reflect when limit reached.
        unless @reflekt_counts[method] >= @@reflekt.reflect_limit

          # Get current execution.
          execution = @@reflekt.stack.peek()

          # When stack empty or past execution done reflecting.
          if execution.nil? || execution.has_finished_reflecting?

            # Create execution.
            execution = Execution.new(self, method, @@reflekt.reflect_amount, @@reflekt.stack)

            @@reflekt.stack.push(execution)

          end

          # Reflect.
          # The first method call in the Execution creates a Reflection.
          # Subsequent method calls are shadow executions on cloned objects.
          if execution.has_empty_reflections? && !execution.is_reflecting?
            execution.is_reflecting = true

            # Create control.
            control = Control.new(execution, 1, @@reflekt.ruler)
            execution.control = control

            # Execute control.
            control.reflect(*args)

            # Save control.
            @@reflekt.db.get("controls").push(control.result())

            # Multiple reflections per execution.
            execution.reflections.each_with_index do |value, index|

              # Create reflection.
              reflection = Reflection.new(execution, index + 1, @@reflekt.ruler)
              execution.reflections[index] = reflection

              # Execute reflection.
              reflection.reflect(*args)
              @reflekt_counts[method] = @reflekt_counts[method] + 1

              # Save reflection.
              @@reflekt.db.get("reflections").push(reflection.result())

            end

            # Save results.
            @@reflekt.db.write()

            # Render results.
            @@reflekt.renderer.render()

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
    @@reflekt.db = Rowdb.new(@@reflekt.output_path + '/db.js')
    @@reflekt.db.defaults({ :reflekt => { :api_version => 1 }})

    # Create shadow execution stack.
    @@reflekt.stack = ShadowStack.new()

    # Create rules.
    @@reflekt.ruler = Ruler.new()
    # TODO: Fix Rowdb.get(path) not returning values at path after Rowdb.push()?
    values = @@reflekt.db.value()
    values.each do |klass, class_values|

      class_values.each do |method_name, method_items|
        next if method_items.nil?
        next unless method_items.class == Hash
        if method_items.key? "controls"

          method = method_name.to_sym

          @@reflekt.ruler.load(klass, method, method_items['controls'])
          @@reflekt.ruler.train(klass, method)

        end
      end

    end

    # The amount of reflections to create per method call.
    @@reflekt.reflect_amount = 2

    # Limit the amount of reflections that can be created per instance method.
    # A method called thousands of times doesn't need that many reflections.
    @@reflekt.reflect_limit = 10

    # Create renderer.
    @@reflekt.renderer = Renderer.new(@@reflekt.path, @@reflekt.output_path)

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
      @@reflekt.reflect_limit = amount
    end

  end

end
