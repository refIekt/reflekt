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
require 'lit_cli'

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

  include LitCLI

  ##
  # Reflect-Execute loop.
  #
  # Reflect each method before finally executing it.
  #
  # @loop
  #   1. Reflekt is prepended to a class and setup
  #   2. The method is overridden on class instantiation
  #   3. An Action is created on method call
  #   4. Many Refections are created per Action
  #   5. Each Reflection executes on cloned data
  #   6. The original method executes
  #
  # @see https://reflekt.dev/docs/reflect-execute-loop
  #
  # @scope self [Object] Refers to the class that Reflekt is prepended to.
  ##
  def initialize(*args)

    if @@reflekt.config.enabled
      @reflekt_initialized = false
      @reflekt_counts = {} # TODO: Store on @@reflekt.counts, key by instance ID.

      🔥 "Initialize #{self.class}", :info, :setup

      # Override methods.
      Reflekt.get_methods(self).each do |method|
        @reflekt_counts[method] = 0
        Reflekt.override_method(self, method)
      end

      @reflekt_initialized = true
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
    klass.define_singleton_method(method) do |*args|

      # When method called in flow.
      if @reflekt_initialized
        unless @@reflekt.error

          🔥 "#{klass.class}.#{method}() called.", :info, :action

          # Get current action.
          action = @@reflekt.stack.peek()
          if action.nil?
            🔥 "First action ever created.", :info, :action
            action = Action.new(klass, method, @@reflekt.config.reflect_amount, @@reflekt.stack)
            @@reflekt.stack.push(action)
          end

          # New action when old action done reflecting.
          if action.has_finished_reflecting?
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

            🔥 "Create control for #{method} action and reflect", :info, :control
            control = Control.new(action, 0, @@reflekt.aggregator)
            action.control = control
            unless klass.class.reflekt_skipped?(method) || (@reflekt_counts[method] >= @@reflekt.config.reflect_limit)
              control.reflect(*args)
            end

            unless control.status == :error

              ## Save control as a reflection.
              #@@reflekt.db.get("reflections").push(control.serialize())

              ## Multiple experiments per action.
              #action.experiments.each_with_index do |value, index|

              #  # Create experiment.
              #  experiment = Experiment.new(action, index + 1, @@reflekt.aggregator)
              #  action.experiments[index] = experiment

              #  # Reflect experiment.
              #  experiment.reflect(*args)
              #  @reflekt_counts[method] = @reflekt_counts[method] + 1

              #  # Save experiment.
              #  @@reflekt.db.get("reflections").push(experiment.serialize())

              #end

              ## Save results.
              #@@reflekt.db.get("controls").push(control.serialize())
              #@@reflekt.db.write()

              ## Render results.
              #@@reflekt.renderer.render()

            # Stop reflecting when control fails to execute.
            else
              @@reflekt.error = true
            end

            action.is_reflecting = false
          end

          # Don't execute skipped methods when reflecting.
          unless action.is_reflecting? && klass.class.reflekt_skipped?(method)
            🔥 "Continue original execution / shadow execution.", :info, :action
            super *args
          end

        # Finish execution when control reflection fails.
        else
          super *args
        end
      # When method called in constructor.
      else
        🔥 "#{klass} #{method}() is not reflected in constructor.", :info, :setup
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

    LitCLI.configure do |config|
      config.types = {
        :info => { icon: "ℹ", color: :blue },
        :pass => { icon: "✔", color: :green },
        :warn => { icon: "⚠", color: :yellow },
        :fail => { icon: "⨯", color: :red },
        :error => { icon: "!", color: :red },
        :debug => { icon: "?", color: :purple },
      }
      config.types = {
        :setup => { styles: [:dim, :bold, :upcase] },
        :action => { color: :red, styles: [:bold, :upcase] },
        :control => { color: :blue, styles: [:bold, :upcase] },
        :experiment => { color: :green, styles: [:bold, :upcase] },
      }
    end

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
