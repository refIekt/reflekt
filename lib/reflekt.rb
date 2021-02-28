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
  # Setup Reflekt per class.
  # Override methods on class instantiation.
  #
  # @scope self [Object] Refers to the class that Reflekt is prepended to.
  ##
  def initialize(*args)
    if @@reflekt.config.enabled
      @reflekt_initialized = false

      🔥"Initialize", :info, :setup, self.class

      # Override methods.
      Reflekt.get_methods(self).each do |method|
        Reflekt.setup_count(self, method)
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

        ##
        # Reflect-Execute loop.
        #
        # Reflect each method before finally executing it.
        #
        # @loop
        #   1. The first method call creates an action
        #   2. The action creates reflections and calls the method again
        #   3. Subsequent method calls execute these reflections
        #   4. Each reflection executes on cloned data
        #   5. The original method call completes execution
        #
        # @see https://reflekt.dev/docs/reflect-execute-loop
        ##

        unless @@reflekt.error

          action = @@reflekt.stack.peek()

          # New action when old action done reflecting.
          if action.nil? || action.has_finished_loop?
            🔥"^ Create action for #{method}()", :info, :action, klass.class
            action = Action.new(klass, method, @@reflekt.config, @@reflekt.db, @@reflekt.stack, @@reflekt.aggregator)
            @@reflekt.stack.push(action)
          end

          ##
          # REFLECT
          ##

          unless action.is_reflecting? && klass.class.reflekt_skipped?(method) || Reflekt.count(klass, method) >= @@reflekt.config.reflect_limit
            unless action.is_actioned?
              action.is_actioned = true
              action.is_reflecting = true

              action.reflect(*args)
              if action.control.status == :error
                @@reflekt.error = action.control.message
              end

              # Render results.
              @@reflekt.renderer.render()

              action.is_reflecting = false
            end
          else
            🔥"> Skip reflection of #{method}()", :skip, :reflect, klass.class
          end

          ##
          # EXECUTE
          ##

          unless action.is_reflecting? && klass.class.reflekt_skipped?(method)
            🔥"> Execute #{method}()", :info, :execute, klass.class
            super *args
          end

        # Finish execution if control encounters unrecoverable error.
        else
          🔥"Reflection error, finishing original execution...", :error, :reflect, klass.class
          super *args
        end

      # When method called in constructor.
      else
        p "Reflection unsupported in constructor for #{method}()", :info, :setup, klass.class
        super *args
      end
    end
  end

  def self.setup_count(klass, method)
    caller_id = klass.object_id
    @@reflekt.counts[caller_id] = {} unless @@reflekt.counts.has_key? caller_id
    @@reflekt.counts[caller_id][method] = 0 unless @@reflekt.counts[caller_id].has_key? method
  end

  def self.count(klass, method)
    count = @@reflekt.counts.dig(klass.object_id, method) || 0
    count
  end

  def self.increase_count(klass, method)
    caller_id = klass.object_id
    @@reflekt.counts[caller_id][method] = @@reflekt.counts[caller_id][method] + 1
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
  #   - output_path [String] Absolute path to the reflections directory.
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
        :skip => { icon: "⨯", color: :yellow, styles: [:upcase] },
        :warn => { icon: "⚠", color: :yellow, styles: [:upcase] },
        :fail => { icon: "⨯", color: :red, styles: [:upcase] },
        :error => { icon: "!", color: :red, styles: [:upcase] },
        :debug => { icon: "?", color: :purple, styles: [:upcase] },
      }
      config.types = {
        :setup => { styles: [:dim, :bold, :capitalize] },
        :event => { color: :yellow, styles: [:bold, :capitalize] },
        :reflect => { color: :yellow, styles: [:bold, :capitalize] },
        :result => { color: :yellow, styles: [:bold, :capitalize] },
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
