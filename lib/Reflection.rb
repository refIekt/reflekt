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
    @inputs = []
    @output = nil

    # Clone the execution's calling object.
    @clone = Clone.new(execution)
    @clone_id = nil

    # Result.
    @status = :pass
    @time = Time.now.to_i

  end

  ##
  # Reflect on a method.
  #
  # Creates a shadow execution stack.
  # @param *args [Dynamic] The method's arguments.
  ##
  def reflect(*args)

    # Get aggregated RuleSets.
    agg_input_rule_sets = @aggregator.get_input_rule_sets(@klass, @method)
    agg_output_rule_set = @aggregator.get_output_rule_set(@klass, @method)

    # Create random arguments.
    new_args = randomize(args)

    # Create metadata for each argument.
    @inputs = MetaBuilder.create_many(new_args)

    # Action method with new arguments.
    begin

      # Validate input with aggregated control RuleSets.
      unless agg_input_rule_sets.nil?
        unless @aggregator.validate_inputs(new_args, agg_input_rule_sets)
          @status = :fail
        end
      end

      # Run reflection.
      output = @clone.call(@method, *new_args)
      @output = MetaBuilder.create(output)

      # Validate output with aggregated control RuleSets.
      unless agg_output_rule_set.nil?
        unless @aggregator.validate_output(output, agg_output_rule_set)
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
  # Create random values for each argument.
  #
  # @param args [Dynamic] The arguments to create random values for.
  # @return [Dynamic] Random arguments.
  ##
  def randomize(args)

    random_args = []

    args.each do |arg|
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
      :inputs => [],
      :output => @output,
    }
    @inputs.each do |meta|
      reflection[:inputs] << meta.result()
    end

    return reflection

  end

end
