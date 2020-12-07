################################################################################
# A snapshot of simulated data.
#
# @note
#   A reflection's random value is within the bounds of aggregated control rule sets
#   as well as as the arg type being inputted into the current control reflection.
#
# @nomenclature
#   args, inputs/output and meta represent different stages of a value.
#
# @hierachy
#   1. Execution
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
  # @param execution [Execution] The Execution that created this Reflection.
  # @param number [Integer] Multiple Reflections can be created per Execution.
  # @param aggregator [Aggregator] The aggregated RuleSet for this class/method.
  ##
  def initialize(execution, number, aggregator)

    @execution = execution
    @unique_id = execution.unique_id + number
    @number = number

    # Dependency.
    @aggregator = aggregator

    # Caller.
    @klass = execution.klass
    @method = execution.method

    # Metadata.
    @inputs = nil
    @output = nil

    # Clone the execution's calling object.
    # TODO: Abstract away into Clone class.
    @clone = execution.caller_object.clone

    # Result.
    @status = :pass
    @time = Time.now.to_i
    @message = nil

  end

  ##
  # Reflect on a method.
  #
  # Creates a shadow execution.
  # @param *args [Dynamic] The method's arguments.
  ##
  def reflect(*args)

    # Get aggregated rule sets.
    input_rule_sets = @aggregator.get_input_rule_sets(@klass, @method)
    output_rule_set = @aggregator.get_output_rule_set(@klass, @method)

    # When arguments exist.
    unless args.size == 0

      # Create random arguments from aggregated rule sets.
      unless input_rule_sets.nil?

        # Base random arguments on the types of the current arguments.
        if Aggregator.testable?(args, input_rule_sets)

          args = randomize(args, input_rule_sets)

        # TODO: Fallback to argument types from aggregated control rule sets
        # when arg types not testable or reflect_amount above 3.
        else
          @status = :fail
        end

      end

      # Create metadata for each argument.
      # TODO: Create metadata for other inputs such as properties on the instance.
      @inputs = MetaBuilder.create_many(args)

    end

    # Action method with new/old arguments.
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
  # @param args [Dynamic] The arguments to create random values for.
  # @param input_rule_sets [Array] Aggregated rule sets for each argument.
  #
  # @return [Dynamic] Random arguments.
  ##
  def randomize(args, input_rule_sets)

    random_args = []

    args.each_with_index do |arg, arg_num|

      rule_type = Aggregator.value_to_rule_type(arg)
      agg_rule = input_rule_sets[arg_num].rules[rule_type]

      random_args << agg_rule.random()

    end

    return random_args

  end

  ##
  # Get the results of the reflection.
  #
  # @return [Hash] Reflection metadata.
  ##
  def serialize()

    # The ID of the first execution in the ShadowStack.
    base_id = nil
    unless @execution.base == nil
      base_id = @execution.base.unique_id
    end

    # Build reflection.
    reflection = {
      :base_id => base_id,
      :exe_id => @execution.unique_id,
      :ref_id => @unique_id,
      :ref_num => @number,
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
