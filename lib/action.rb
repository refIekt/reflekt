################################################################################
# A shadow action.
#
# @hierachy
#   1. Action <- YOU ARE HERE
#   2. Reflection
#   3. Meta
################################################################################

module Reflekt
  class Action
    include LitCLI

    attr_accessor :caller_id
    attr_accessor :caller_class
    attr_accessor :caller_object

    attr_accessor :unique_id
    attr_accessor :klass
    attr_accessor :method

    attr_accessor :base
    attr_accessor :child
    attr_accessor :parent

    attr_accessor :control
    attr_accessor :experiments

    attr_accessor :is_base
    attr_accessor :is_actioned
    attr_accessor :is_reflecting

    ##
    # Create Action.
    #
    # @param object [Object] The calling object.
    # @param method [Symbol] The calling method.
    # @param reflect_amount [Integer] The number of experiments to create per action.
    # @param stack [ActionStack] The shadow action call stack.
    ##
    def initialize(caller_object, method, config, db, stack, aggregator)
      @time = Time.now.to_i
      @unique_id = @time + rand(1..99999)
      @base = nil
      @child = nil
      @parent = nil

      # Dependencies.
      @db = db
      @stack = stack
      @aggregator = aggregator

      # Caller.
      @caller_object = caller_object
      @caller_class = caller_object.class
      @caller_id = caller_object.object_id
      @klass = @caller_class.to_s.to_sym
      @method = method

      # Reflections.
      @control = nil
      @experiments = Array.new(config.reflect_amount)

      # State.
      @is_reflecting = false
      if @stack.peek() == nil
        @is_base = true
      else
        @is_base = false
        @base = @stack.base()
      end
    end

    def reflect(*args)

      🔥"^ Create control for #{@method}()", :info, :control, @klass
      @control = Control.new(self, 0, @aggregator)

      @control.reflect(*args)
      🔥"> Reflected control for #{@method}(): #{args}", @control.status, :result, @klass

      # Stop reflecting when control fails to execute.
      unless @control.status == :error

        # Save control.
        @db.get("controls").push(@control.serialize())
        @db.get("reflections").push(@control.serialize())

        # Multiple experiments per action.
        @experiments.each_with_index do |value, index|

          🔥"^ Create experiment ##{index + 1} for #{@method}()", :info, :experiment, @klass
          experiment = Experiment.new(self, index + 1, @aggregator)
          @experiments[index] = experiment

          # Reflect experiment.
          experiment.reflect(*args)
          Reflekt.increase_count(@caller_object, @method)
          🔥"> Reflected experiment ##{index + 1} for #{@method}()", experiment.status, :result, @klass

          # Save experiment.
          @db.get("reflections").push(experiment.serialize())
        end

        # Save results.
        @db.write()
      end
    end

    def is_actioned?
      @is_actioned
    end

    # Is the action currently reflecting methods?
    def is_reflecting?
      @is_reflecting
    end

    def has_empty_experiments?
      @experiments.include? nil
    end

    def has_finished_loop?
      return false if is_actioned? == false
      return false if is_reflecting?
      return false if has_empty_experiments?

      true
    end
  end
end
