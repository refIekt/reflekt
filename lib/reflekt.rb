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

      🔥"Initialize", :info, :setup, self.class

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
  # A method call is tracked as an action.
  # The first method call creates reflections.
  # Subsequent method calls execute these reflections.
  # The final execution returns real data to the original caller.
  #
  # @param klass [Dynamic] The class to override.
  # @param method [Method] The method to override.
  ##
  def self.override_method(klass, method)
    klass.define_singleton_method(method) do |*args|

      # When method called in flow.
      if @reflekt_initialized
        unless @@reflekt.error

          🔥"Get current action", :info, :action, klass.class
          action = @@reflekt.stack.peek()

          ##
          # Reflect.
          ##
          if action.nil? || action.has_finished_loop?

            # New action when old action done reflecting.
            🔥"Create action for #{method}()", :info, :action, klass.class
            action = Action.new(klass, method, @@reflekt.config.reflect_amount, @@reflekt.stack)
            @@reflekt.stack.push(action)

            🔥"Create control for #{method}()", :info, :control, klass.class
            control = Control.new(action, 0, @@reflekt.aggregator)
            action.control = control

            unless klass.class.reflekt_skipped?(method) || (@reflekt_counts[method] >= @@reflekt.config.reflect_limit)
              control.reflect(*args)
              🔥"Reflected control for #{action.method}()", control.status, :control, klass.class
            end

            unless control.status == :error

              # Save control as a reflection.
              @@reflekt.db.get("reflections").push(control.serialize())

              # Multiple experiments per action.
              action.experiments.each_with_index do |value, index|

                🔥""
                🔥"Create experiment ##{index + 1} for #{method}()", :info, :experiment, klass.class
                experiment = Experiment.new(action, index + 1, @@reflekt.aggregator)
                action.experiments[index] = experiment

                # Reflect experiment.
                experiment.reflect(*args)
                @reflekt_counts[method] = @reflekt_counts[method] + 1
                🔥"Reflected experiment ##{index + 1} for #{action.method}()", experiment.status, :experiment, klass.class

                # Save experiment.
                @@reflekt.db.get("reflections").push(experiment.serialize())
              end

              # Save results.
              @@reflekt.db.get("controls").push(control.serialize())
              @@reflekt.db.write()

              # Render results.
              @@reflekt.renderer.render()

            # Stop reflecting when control fails to execute.
            else
              @@reflekt.error = true
            end

            action.is_reflecting = false

          ##
          # Shadow execute.
          ##
          elsif action.is_reflecting
            🔥"Reflect #{method}()", :info, :reflect, klass.class

            # Don't execute skipped methods when reflecting.
            unless klass.class.reflekt_skipped?(method)
              🔥"Shadow execute #{method}()", :info, :execute, klass.class
              super *args
            end
          ##
          # Execute.
          ##
          else
            🔥"Execute #{method}()", :info, :execute, klass.class
            action.has_executed = true
            super *args
          end

        # Finish execution if control encounters unrecoverable error.
        else
          super *args
        end
      # When method called in constructor.
      else
        🔥"Reflection unsupported in constructor for #{method}()", :info, :setup, klass.class
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
      config.statuses = {
        :info => { icon: "ℹ", color: :blue, styles: [:upcase] },
        :pass => { icon: "✔", color: :green, styles: [:upcase] },
        :save => { icon: "✔", color: :green, styles: [:upcase] },
        :warn => { icon: "⚠", color: :yellow, styles: [:upcase] },
        :fail => { icon: "⨯", color: :red, styles: [:upcase] },
        :error => { icon: "!", color: :red, styles: [:upcase] },
        :debug => { icon: "?", color: :purple, styles: [:upcase] },
      }
      config.types = {
        :setup => { styles: [:dim, :bold, :capitalize] },
        :event => { color: :yellow, styles: [:bold, :capitalize] },
        :reflect => { color: :yellow, styles: [:bold, :capitalize] },
        :action => { color: :red, styles: [:bold, :capitalize] },
        :control => { color: :blue, styles: [:bold, :capitalize] },
        :experiment => { color: :green, styles: [:bold, :capitalize] },
        :execute => { color: :purple, styles: [:bold, :capitalize] },
        :meta => { color: :blue, styles: [:bold, :capitalize] },
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
