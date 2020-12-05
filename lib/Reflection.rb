################################################################################
# A snapshot of simulated data.
#
# @nomenclature
#   args, inputs/output and meta represent different stages of a value.
#
# @hierachy
#   1. Execution
#   2. Reflection <- YOU ARE HERE
#   3. Meta
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
    agg_input_rule_sets = @aggregator.get_input_rule_sets(@klass, @method)
    agg_output_rule_set = @aggregator.get_output_rule_set(@klass, @method)

    # When arguments exist.
    unless args.size == 0

      # When aggregated rule sets exist.
      unless agg_input_rule_sets.nil?

        # Randomize arguments from rule sets.
        args = randomize(args, agg_input_rule_sets)

        # Validate arguments against aggregated rule sets.
        unless @aggregator.test_inputs(args, agg_input_rule_sets)
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

      # Validate output with aggregated control rule sets.
      unless agg_output_rule_set.nil?
        unless @aggregator.test_output(output, agg_output_rule_set)
          @status = :fail
        end
      end

    # When fail.
    rescue StandardError => message

      @status = :fail
      @message = message

    end

  end

  ##
  # Create random values for each argument from control reflections.
  #
  # @param args [Dynamic] The arguments to create random values for.
  # @param agg_input_rule_sets [Array] Aggregated rule sets for each argument.
  #
  # @return [Dynamic] Random arguments.
  ##
  def randomize(args, agg_input_rule_sets)

    random_args = []

    args.each_with_index do |arg, index|
      
      case arg
      when Integer
        random_args << rand(999)
      else
        random_args << arg
      end

    end

    return random_args

  end

  ##
  # Get the results of the reflection.
  #
  # @return [Hash] Reflection metadata.
  ##
  def result()

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
        reflection[:inputs] << meta.result()
      end
    end

    unless @output.nil?
      reflection[:output] = @output.result()
    end

    return reflection

  end

end
