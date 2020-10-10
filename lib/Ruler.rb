################################################################################
# RULER
#
# Aggregates a method's input/output.
# Creates a pool of rules from each aggregation.
# Validates input/output against rules.
################################################################################

require 'RulePool'

class Ruler

  INPUT  = "i"
  OUTPUT = "o"
  TYPE   = "T"
  VALUE  = "V"

  attr_accessor :inputs
  attr_accessor :output

  def initialize()

    # Rule Pools.
    @inputs = []
    @output = nil

  end

  def process(controls)

    controls.each_with_index do |control, index|

      # Create rule pools for each input.
      control[INPUT].each_with_index do |input, index|
        unless input.nil?

          if @inputs[index].nil?
            @inputs[index] = RulePool.new()
          end

          @inputs[index].process(input[TYPE], input[VALUE])

        end
      end

      # Create rule pool for the output.
      output = control[OUTPUT]
      unless control[OUTPUT].nil?

        if @output.nil?
          @output = RulePool.new()
        end

        @output.process(output[TYPE], output[VALUE])

      end

    end

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

  # Called on both method arguments and method return value.
  def validate(items, rule_pools)

    # Ensure outputs/input behave as arrays even if they're only one value.
    items = [*items]
    rule_pools = [*rule_pools]
    p rule_pools

    # Default to a PASS result.
    result = true

    # Can't validate an empty rule pool.
    if rule_pools.empty?
      return result
    end

    # Validate each value against each pool of rules for that value.
    items.each_with_index do |value, index|
      rule_pool = rule_pools[index]
      unless rule_pool.validate(value)
        result = false
      end
    end

    return result
  end

end
