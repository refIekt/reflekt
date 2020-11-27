################################################################################
# Reflective testing.
#
# @author
#   Maedi Prichard
#
# @flow
#   1. An Execution is created on method call.
#   2. Many Refections are created per Execution.
#   3. Each Reflection executes on cloned data.
#   4. Flow is returned to the original method.
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

    # Define rules that apply to data types.
    # TODO: Make user configurable.
    rule_map = {
      Array => [ArrayRule],
      TrueClass => [BooleanRule],
      FalseClass => [BooleanRule],
      Integer => [IntegerRule],
      String => [StringRule]
    }

    # Create aggregated rule sets.
    @@reflekt.aggregator = Aggregator.new(rule_map)
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
