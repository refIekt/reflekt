################################################################################
# REFLECTION
#
# A snapshot of simulated data.
#
# Hierachy:
# 1. Execution
# 2. Reflection <- YOU ARE HERE.
# 3. RuleSet
################################################################################

require 'Ruler'

class Reflection

  attr_accessor :clone

  ##
  # Create a Reflection.
  #
  # @param execution [Execution] The Execution that created this Reflection.
  # @param number [Integer] Multiple Reflections can be created per Execution.
  # @param aggregator [Aggregator] The aggregated RuleSets for this class/method.
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

    # RuleSets.
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
  #
  # @param *args [Dynamic] The method's arguments.
  # @return A reflection hash.
  ##
  def reflect(*args)

    # Get aggregated RuleSets.
    input_rule_sets = @aggregator.get_input_rule_sets(@klass, @method)
    output_rule_set = @aggregator.get_output_rule_set(@klass, @method)

    # Create deviated arguments.
    args.each do |arg|
      case arg
      when Integer
        new_args << rand(999)
      else
        new_args << arg
      end
    end

    # Action method with new arguments.
    begin

      # Validate input with aggregated control rule sets.
      unless input_rule_sets.nil?
        unless @ruler.validate_inputs(new_args, input_rule_sets)
          @status = :fail
        end
      end

      # Run reflection.
      output = @clone.send(@method, *new_args)

      # Validate output with aggregated control rule sets.
      unless output_rule_set.nil?
        unless @ruler.validate_output(output, output_rule_set)
          @status = :fail
        end
      end

    # When fail.
    rescue StandardError => message
      @status = :fail
      @message = message
    end

  end

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
