################################################################################
# Reflective testing.
#
# @author Maedi Prichard
#
# @flow
#   1. Reflekt is prepended to a class and setup.
#   2. When a class insantiates so does Reflekt.
#   3. An Execution is created on method call.
#   4. Many Refections are created per Execution.
#   5. Each Reflection executes on cloned data.
#   6. Flow is returned to the original method.
#
# @usage
#   class ExampleClass
#     prepend Reflekt
################################################################################

require 'set'
require 'erb'
require 'rowdb'
require 'Accessor'
require 'Aggregator'
require 'Control'
require 'Execution'
require 'Reflection'
require 'Renderer'
require 'ShadowStack'
# Require all rules.
Dir[File.join(__dir__, 'rules', '*.rb')].each { |file| require file }

module Reflekt

  def initialize(*args)

    @reflekt_counts = {}

    # Get child and parent instance methods.
    parent_instance_methods = self.class.superclass.instance_methods(false)
    child_instance_methods = self.class.instance_methods(false)
    instance_methods = parent_instance_methods + child_instance_methods

    # TODO: Include core methods like "Array.include?".
    instance_methods.each do |method|

      @reflekt_counts[method] = 0

      # When method called in flow.
      self.define_singleton_method(method) do |*args|

        # Get current execution.
        execution = @@reflekt.stack.peek()

        # Don't reflect when reflect limit reached or method skipped.
        unless (@reflekt_counts[method] >= @@reflekt.reflect_limit) || self.class.reflekt_skipped?(method)

          # When stack empty or past execution done reflecting.
          if execution.nil? || execution.has_finished_reflecting?

            # Create execution.
            execution = Execution.new(self, method, @@reflekt.reflect_amount, @@reflekt.stack)

            @@reflekt.stack.push(execution)

          end

          ##
          # Reflect the execution.
          #
          # The first method call in the Execution creates a Reflection.
          # Subsequent method calls are shadow executions on cloned objects.
          ##
          if execution.has_empty_reflections? && !execution.is_reflecting?
            execution.is_reflecting = true

            # Create control.
            control = Control.new(execution, 1, @@reflekt.aggregator)
            execution.control = control

            # Execute control.
            control.reflect(*args)

            # Save control.
            @@reflekt.db.get("controls").push(control.result())

            # Multiple reflections per execution.
            execution.reflections.each_with_index do |value, index|

              # Create reflection.
              reflection = Reflection.new(execution, index + 1, @@reflekt.aggregator)
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

        # Don't execute skipped methods when reflecting.
        unless execution.is_reflecting? && self.class.reflekt_skipped?(method)

          # Continue execution / shadow execution.
          super *args

        end

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
    $ENV[:reflekt][:output_directory] = "reflections"

    # Set configuration.
    @@reflekt.path = File.dirname(File.realpath(__FILE__))

    # Get reflections directory path from config or current execution path.
    if $ENV[:reflekt][:output_path]
      @@reflekt.output_path = File.join($ENV[:reflekt][:output_path], $ENV[:reflekt][:output_directory])
    else
      @@reflekt.output_path = File.join(Dir.pwd, $ENV[:reflekt][:output_directory])
    end

    # Create reflections directory.
    unless Dir.exist? @@reflekt.output_path
      Dir.mkdir(@@reflekt.output_path)
    end

    # Create database.
    @@reflekt.db = Rowdb.new(@@reflekt.output_path + '/db.js')
    @@reflekt.db.defaults({ :reflekt => { :api_version => 1 }})
    # @TODO Fix Rowdb.get(path) not returning values at path after Rowdb.push()
    db = @@reflekt.db.value()

    # Create shadow stack.
    @@reflekt.stack = ShadowStack.new()

    # Define the rules that apply to meta types.
    # TODO: Make user configurable.
    meta_map = {
      :array  => [ArrayRule],
      :bool   => [BooleanRule],
      :int    => [IntegerRule],
      :string => [StringRule]
    }

    # Create aggregated rule sets.
    @@reflekt.aggregator = Aggregator.new(meta_map)
    @@reflekt.aggregator.train(db[:controls])

    # The amount of reflections to create per method call.
    # TODO: Make user configurable.
    @@reflekt.reflect_amount = 2

    # Limit the amount of reflections that can be created per instance method.
    # A method called thousands of times doesn't need that many reflections.
    # TODO: Make user configurable.
    @@reflekt.reflect_limit = 10

    # Create renderer.
    @@reflekt.renderer = Renderer.new(@@reflekt.path, @@reflekt.output_path)

    return true

  end

  module SingletonClassMethods

    @@reflekt_skipped_methods = Set.new()

    ##
    # Skip a method.
    #
    # @note
    #  Class variables cascade to child classes.
    #  So a reflekt_skip on the parent class will persist to the child class.
    #
    # @param method [Symbol] The method name.
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
