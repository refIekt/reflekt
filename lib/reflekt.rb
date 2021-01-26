################################################################################
# Reflective testing.
#
# @author Maedi Prichard
#
# @usage
#   class ExampleClass
#     prepend Reflekt
################################################################################

require 'set'
require 'erb'
require 'rowdb'
require_relative 'accessor'
require_relative 'action'
require_relative 'action_stack'
require_relative 'config'
require_relative 'control'
require_relative 'experiment'
require_relative 'renderer'
require_relative 'rule_set_aggregator'
# Require all rules in rules directory.
Dir[File.join(__dir__, 'rules', '*.rb')].each { |file| require_relative file }

module Reflekt

  ##
  # Reflect-Execute loop.
  #
  # Reflect each method before it executes.
  #
  # @loop
  #   1. Reflekt is prepended to a class and setup
  #   2. The method is overridden on class instantiation
  #   3. An Action is created on method call
  #   4. Many Refections are created per Action
  #   5. Each Reflection executes on cloned data
  #   6. Flow is returned to the original method
  #
  # @see https://reflekt.dev/docs/reflect-execute-loop
  #
  # @scope self [Object] Refers to the class that Reflekt is prepended to.
  ##
  def initialize(*args)

    # TODO: Store counts on @@reflekt.counts and key by instance ID.
    @reflekt_counts = {}

    # Override methods.
    Reflekt.get_methods(self).each do |method|
      @reflekt_counts[method] = 0
      Reflekt.override_method(self, method)
    end

    # Continue initialization.
    super

  end

  ##
  # Get child and parent instance methods.
  #
  # TODO: Include methods from all ancestors.
  # TODO: Include core methods like "Array.include?".
  ##
  def self.get_methods(klass)
    child_instance_methods = klass.class.instance_methods(false)
    parent_instance_methods = klass.class.superclass.instance_methods(false)
    return child_instance_methods + parent_instance_methods
  end

  ##
  # Override a method.
  #
  # @param klass [Dynamic] The class to override.
  # @param method [Method] The method to override.
  ##
  def self.override_method(klass, method)

    # When method called in flow.
    klass.define_singleton_method(method) do |*args|

      # When Reflekt enabled and control has reflected so far without error.
      if @@reflekt.config.enabled && !@@reflekt.error

        # Get current action.
        action = @@reflekt.stack.peek()

        # Don't reflect when reflect limit reached or method skipped.
        unless (@reflekt_counts[method] >= @@reflekt.config.reflect_limit) || klass.class.reflekt_skipped?(method)

          # Create action when stack empty or past action done reflecting.
          if action.nil? || action.has_finished_reflecting?
            action = Action.new(klass, method, @@reflekt.config.reflect_amount, @@reflekt.stack)
            @@reflekt.stack.push(action)
          end

          ##
          # Reflect the action.
          #
          # The first method call in the action creates a reflection.
          # Subsequent method calls are shadow actions which return to the reflection.
          ##
          if action.has_empty_experiments? && !action.is_reflecting?
            action.is_reflecting = true

            # Create control.
            control = Control.new(action, 0, @@reflekt.aggregator)
            action.control = control

            # Execute control.
            control.reflect(*args)

            # Stop reflecting when control fails to execute.
            if control.status == :error
              @@reflekt.error = true
            # Continue reflecting when control executes succesfully.
            else

              # Save control as a reflection.
              @@reflekt.db.get("reflections").push(control.serialize())

              # Multiple experiments per action.
              action.experiments.each_with_index do |value, index|

                # Create experiment.
                experiment = Experiment.new(action, index + 1, @@reflekt.aggregator)
                action.experiments[index] = experiment

                # Execute experiment.
                experiment.reflect(*args)
                @reflekt_counts[method] = @reflekt_counts[method] + 1

                # Save experiment.
                @@reflekt.db.get("reflections").push(experiment.serialize())

              end

              # Save results.
              @@reflekt.db.get("controls").push(control.serialize())
              @@reflekt.db.write()

              # Render results.
              @@reflekt.renderer.render()

            end

            action.is_reflecting = false
          end

        end

        # Don't execute skipped methods when reflecting.
        unless action.is_reflecting? && klass.class.reflekt_skipped?(method)
          # Continue action / shadow action.
          super *args
        end

      # When Reflekt disabled or control reflection failed.
      else
        # Continue action.
        super *args
      end

    end

  end

  ##
  # Configure Config singleton.
  ##
  def self.configure
    reflekt_setup_class()

    yield(@@reflekt.config)
  end

  private

  def self.prepended(base)
    # Prepend class methods to the instance's singleton class.
    base.singleton_class.prepend(SingletonClassMethods)

    reflekt_setup_class()
  end

  ##
  # Setup class.
  #
  # @paths
  #   - package_path [String] Absolute path to the library itself.
  #   - project_path [String] Absolute path to the project root.
  #   - output_path [String] Name of the reflections directory.
  ##
  def self.reflekt_setup_class()

    # Only setup once.
    return if defined? @@reflekt

    @@reflekt = Accessor.new()
    @@reflekt.config = Config.new()
    @@reflekt.stack = ActionStack.new()

    # Setup paths.
    @@reflekt.package_path = File.dirname(File.realpath(__FILE__))
    @@reflekt.project_path = @@reflekt.config.project_path
    @@reflekt.output_path = File.join(@@reflekt.project_path, @@reflekt.config.output_directory)
    unless Dir.exist? @@reflekt.output_path
      Dir.mkdir(@@reflekt.output_path)
    end

    # Setup database.
    @@reflekt.db = Rowdb.new(@@reflekt.output_path + '/db.js')
    @@reflekt.db.defaults({ :reflekt => { :api_version => 1 }})
    # TODO: Fix Rowdb.get(path) not returning values at path after Rowdb.push()
    db = @@reflekt.db.value()

    # Train aggregated rule sets.
    @@reflekt.aggregator = RuleSetAggregator.new(@@reflekt.config.meta_map)
    @@reflekt.aggregator.train(db[:controls])

    # Setup renderer.
    @@reflekt.renderer = Renderer.new(@@reflekt.package_path, @@reflekt.output_path)

    return true
  end

  ##
  # Publicly accessible class methods in the class that Reflekt is prepended to.
  ##
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
  end

end
