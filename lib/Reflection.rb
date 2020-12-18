################################################################################
# A snapshot of random data.
#
# @note
#   A reflection's random value is within the bounds of aggregated control rule sets
#   as well as as the arg type being inputted into the current control reflection.
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

require 'Clone'
require 'MetaBuilder'

class Reflection

  attr_reader :status

  ##
  # Create a Reflection.
  #
  # @param action [Action] The Action that created this Reflection.
  # @param number [Integer] Multiple Reflections can be created per Action.
  # @param aggregator [Aggregator] The aggregated RuleSet for this class/method.
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
  # Creates a shadow action.
  # @param *args [Dynamic] The method's arguments.
  ##
  def reflect(*args)

    # Get aggregated rule sets.
    input_rule_sets = @aggregator.get_input_rule_sets(@klass, @method)
    output_rule_set = @aggregator.get_output_rule_set(@klass, @method)

    # Fail when no trained rule sets.
    if input_rule_sets.nil?
      @status = :fail
    end

    # When arguments exist.
    unless args.size == 0

      # Create random arguments from aggregated rule sets.
      unless input_rule_sets.nil?
        args = randomize(args, input_rule_sets)
      end

      # Create metadata for each argument.
      # TODO: Create metadata for other inputs such as instance variables.
      @inputs = MetaBuilder.create_many(args)

    end

    # Action method with random arguments.
    begin

      # Run reflection.
      output = @clone.send(@method, *args)
      @output = MetaBuilder.create(output)

      # Validate output against aggregated control rule sets.
      unless output_rule_set.nil?
        unless @aggregator.test_output(output, output_rule_set)
          @status = :fail
        end
      end

    # When a system error occurs.
    rescue StandardError => message

      @status = :fail
      @message = message

    end

  end

  ##
  # Create random values for each argument from control reflections.
  #
  # @param args [Dynamic] The arguments to mirror random values for.
  # @param input_rule_sets [Array] Aggregated rule sets for each argument.
  #
  # @return [Dynamic] Random arguments.
  ##
  def randomize(args, input_rule_sets)

    random_args = []

    args.each_with_index do |arg, arg_num|

      # Get a random rule in the rule set.
      rules = input_rule_sets[arg_num].rules
      agg_rule = rules[rules.keys.sample]

      # Create a random value that follows that rule.
      random_args << agg_rule.random()

    end

    return random_args

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
