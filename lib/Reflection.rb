################################################################################
# A snapshot of simulated data.
#
# @nomenclature
#   args/inputs/values are the same thing but at a different stage of lifecycle.
# @hierachy
#   1. Execution
#   2. Reflection
#   3. RuleSet
################################################################################

class Reflection

  attr_accessor :clone

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

    # Rule sets.
    @inputs = []
    @output = nil

    # Clone the execution's calling object.
    @clone = execution.caller_object.clone
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

    # Create RuleSet for each argument.
    @input = create_rule_sets(new_args)

    # Action method with new arguments.
    begin

      # Validate input with aggregated control RuleSets.
      unless agg_input_rule_sets.nil?
        unless @aggregator.validate_inputs(new_args, agg_input_rule_sets)
          @status = :fail
        end
      end

      # Run reflection.
      output = @clone.send(@method, *new_args)
      @output = create_rule_set(output)

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

  def create_rule_sets(args)

    rule_sets = []

    args.each do |arg|
      rule_sets << create_rule_set(arg)
    end

    rule_sets
  end

  def create_rule_set(arg)

    rule_set = RuleSet.new()
    type = arg.class.to_s

    # Creates values for matching data type.
    case type
    when "Integer"
      rule = IntegerRule.new()
      rule.train(arg)
      rule_set.rules[IntegerRule] = rule
    when "String"
      rule = StringRule.new()
      rule.train(arg)
      rule_set.rules[StringRule] = rule
    end

    rule_set
  end

  ##
  # Provide the results of the reflection.
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
      :inputs => @inputs,
      :output => @output,
      :message => @message
    }

    return reflection

  end

end
