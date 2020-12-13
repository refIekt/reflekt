################################################################################
# Reflective testing.
#
# @author Maedi Prichard
#
# @flow
#   1. Reflekt is prepended to a class and setup.
#   2. When a class insantiates so does Reflekt.
#   3. An Action is created on method call.
#   4. Many Refections are created per Action.
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
require 'Config'
require 'Control'
require 'Action'
require 'Reflection'
require 'Renderer'
require 'ShadowStack'
# Require all rules.
Dir[File.join(__dir__, 'rules', '*.rb')].each { |file| require file }

module Reflekt

  def initialize(*args)

    # TODO: Store counts on @@reflekt and key by instance ID.
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

        # When Reflekt enabled and control reflection has executed without error.
        if @@reflekt.config.enabled && !@@reflekt.error

          # Get current action.
          action = @@reflekt.stack.peek()

          # Don't reflect when reflect limit reached or method skipped.
          unless (@reflekt_counts[method] >= @@reflekt.config.reflect_limit) || self.class.reflekt_skipped?(method)

            # When stack empty or past action done reflecting.
            if action.nil? || action.has_finished_reflecting?

              # Create action.
              action = Action.new(self, method, @@reflekt.config.reflect_amount, @@reflekt.stack)

              @@reflekt.stack.push(action)

            end

            ##
            # Reflect the action.
            #
            # The first method call in the action creates a reflection.
            # Then method calls are shadow actions which return to the reflection.
            ##
            if action.has_empty_reflections? && !action.is_reflecting?
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

                # Save control as a reflection when it introduces new rules.
                @@reflekt.db.get("reflections").push(control.serialize()) # if control.status == :fail

                # Multiple reflections per action.
                action.reflections.each_with_index do |value, index|

                  # Create reflection.
                  reflection = Reflection.new(action, index + 1, @@reflekt.aggregator)
                  action.reflections[index] = reflection

                  # Execute reflection.
                  reflection.reflect(*args)
                  @reflekt_counts[method] = @reflekt_counts[method] + 1

                  # Save reflection.
                  @@reflekt.db.get("reflections").push(reflection.serialize())

                end

                # Save control when it introduces new rules.
                @@reflekt.db.get("controls").push(control.serialize()) # if control.status == :fail

                # Save results.
                @@reflekt.db.write()

                # Render results.
                @@reflekt.renderer.render()

              end

              action.is_reflecting = false
            end

          end

          # Don't execute skipped methods when reflecting.
          unless action.is_reflecting? && self.class.reflekt_skipped?(method)

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

    # Continue initialization.
    super

  end

  ##
  # Provide Config instance to block.
  ##
  def self.configure
    yield(@@reflekt.config)
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
    @@reflekt.config = Config.new()

    # Set configuration.
    @@reflekt.path = File.dirname(File.realpath(__FILE__))

    # Get reflections directory path from config or current action path.
    if @@reflekt.config.output_path
      @@reflekt.output_path = File.join(@@reflekt.config.output_path, @@reflekt.config.output_directory)
    else
      @@reflekt.output_path = File.join(Dir.pwd, @@reflekt.config.output_directory)
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

    # Create aggregated rule sets.
    @@reflekt.aggregator = Aggregator.new(@@reflekt.config.meta_map)
    @@reflekt.aggregator.train(db[:controls])

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

    #def reflekt_limit(amount)
    #  @@reflekt.reflect_limit = amount
    #end

  end

end
