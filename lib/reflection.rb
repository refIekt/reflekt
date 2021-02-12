################################################################################
# A snapshot of real or random data.
#
# @pattern Abstract class
#
# @nomenclature
#   args, inputs/output and meta represent different stages of a value.
#
# @hierachy
#   1. Action
#   2. Reflection <- YOU ARE HERE
#   3. Meta
#
# @status
#   - :pass [Symbol] The reflection passes the rules.
#   - :fail [Symbol] The reflection fails the rules or produces a system error.
#   - :error [Symbol] The control reflection produces a system error.
################################################################################

require_relative 'clone'
require_relative 'meta_builder'

module Reflekt
  class Reflection
    include LitCLI

    attr_reader :status

    ##
    # Create a reflection.
    #
    # @param action [Action] The Action that created this Reflection.
    # @param number [Integer] Multiple Reflections can be created per Action.
    # @param aggregator [RuleSetAggregator] The aggregated RuleSet for this class/method.
    ##
    def initialize(action, number, aggregator)
      @action = action
      @unique_id = action.unique_id + number
      @number = number

      # Dependency.
      @aggregator = aggregator

      # Caller.
      @klass = action.klass
      @method = action.method

      # Metadata.
      @inputs = nil
      @output = nil

      # Clone the action's calling object.
      # TODO: Abstract away into Clone class.
      @clone = action.caller_object.clone

      # Result.
      @status = :pass
      @time = Time.now.to_i
      @message = nil
    end

    ##
    # Reflect on a method.
    #
    # Create a shadow action.
    # @param *args [Dynamic] The method's arguments.
    ##
    def reflect(*args)
      # Implemented by Control and Experiment.
    end

    ##
    # Get the results of the reflection.
    #
    # @keys
    #   - eid [Integer] Execution ID
    #   - aid [Integer] Action ID
    #   - rid [Integer] Reflection ID
    #   - num [Integer] Reflection number
    #
    # @return [Hash] Reflection metadata.
    ##
    def serialize()

      # Create execution ID from the ID of the first action in   the ActionStack.
      execution_id = @action.unique_id
      unless @action.base.nil?
        execution_id = @action.base.unique_id
      end

      # Build reflection.
      reflection = {
        :eid => execution_id,
        :aid => @action.unique_id,
        :rid => @unique_id,
        :num => @number,
        :time => @time,
        :class => @klass,
        :method => @method,
        :status => @status,
        :message => @message,
        :inputs => nil,
        :output => nil,
      }

      # TODO: After the last experiment for an action is completed, serialize()
      #       appears to be called twice. Possibly due to inheritance.
      🔥"Save meta for #{@method}()", :save, :meta, @klass

      unless @inputs.nil?
        reflection[:inputs] = []
        @inputs.each do |meta|
          reflection[:inputs] << meta.serialize()
        end
      end

      unless @output.nil?
        reflection[:output] = @output.serialize()
      end

      return reflection

    end

  end
end
