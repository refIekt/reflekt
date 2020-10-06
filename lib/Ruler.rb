################################################################################
# RULER
#
# Aggregate a method's inputs and output into a series of generic rules.
################################################################################

require 'RulePool'

class Ruler

  INPUT  = "i"
  OUTPUT = "o"
  TYPE   = "T"
  VALUE  = "V"

  def initialize()

    # Reflections.
    @controls = nil
    # Arguments.
    @inputs = []
    @output = nil

  end

  def load(controls)

    @controls = controls
    @controls.each_with_index do |control, index|

      # Create rules for each input.
      control[INPUT].each_with_index do |input, index|
        unless input.nil?
          @inputs[index] = load_rule_pool(@inputs[index], input[TYPE], input[VALUE])
        end
      end

      # Create rules for the output.
      output = control[OUTPUT]
      unless control[OUTPUT].nil?
        @output = load_rule_pool(@output, output[TYPE], output[VALUE])
      end

    end

  end

  def load_rule_pool(rule_pool, type, value)

    if rule_pool.nil?
      rule_pool = RulePool.new()
    end

    # Track data type.
    rule_pool.types << type

    # Get rule for this data type.
    rule = nil

    case type
    when "Integer"
      unless rule_pool.rules.key? IntegerRule
        rule = IntegerRule.new()
        rule_pool.rules << rule
      else
        rule = rule_pool.rules[IntegerRule]
      end
    when "String"
      unless rule_pool.rules.key? StringRule
        rule = StringRule.new()
        rule_pool.rules << rule
      else
        rule = rule_pool.rules[IntegerRule]
      end
    end

    # Add value to rule.
    unless rule.nil?
      rule.load(value)
    end

    return rule_pool

  end

  def train()

    @inputs.each do |rule_pool|
      unless rule_pool.nil?
        rule_pool.train()
      end
    end

    unless @output.nil?
      @output.train()
    end

  end

  def validate_inputs(inputs)
    result = true

    inputs.each_with_index do |value, index|
      rule_pool = @inputs[index]
      unless rule_pool.validate(input)
        result = false
      end
    end

    return result
  end

  def validate_output(output)
    result = true

    rule_pool = @output
    unless rule_pool.validate(output)
      result = false
    end

    return result
  end

end
