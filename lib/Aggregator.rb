################################################################################
# AGGREGATOR
#
# Aggregates rule sets from control rule sets.
# Validates reflection arguments against aggregated rule sets.
#
# Hierachy:
# 1. Aggregator <- YOU ARE HERE.
# 2. RuleSet
# 3. AggRule
################################################################################

require 'RuleSet'

class Aggregator

  def initialize()

    # Key by class and method.
    @rule_sets = {}

  end

  ##
  # Get input rule sets.
  #
  # @param klass [Symbol]
  # @param method [Symbol]
  # @return [Array]
  ##
  def get_input_rule_sets(klass, method)
    return @rule_sets.dig(klass, method, :inputs)
  end

  ##
  # Get input aggregated rule set.
  #
  # @param klass [Symbol]
  # @param method [Symbol]
  # @return [RuleSet]
  ##
  def get_input_rule_set(klass, method, arg_num)
    @rule_sets.dig(klass, method, :inputs, arg_num)
  end

  ##
  # Get output aggregated rule set.
  #
  # @param klass [Symbol]
  # @param method [Symbol]
  # @return [RuleSet]
  ##
  def get_output_rule_set(klass, method)
    @rule_sets.dig(klass, method, :output)
  end

  ##
  # Set input aggregated rule set.
  #
  # @param klass [Symbol]
  # @param method [Symbol]
  ##
  def set_input_rule_set(klass, method, arg_num, rule_set)
    # Set defaults.
    @rule_sets[klass] = {} unless @rule_sets.key? klass
    @rule_sets[klass][method] = {} unless @rule_sets[klass].key? method
    @rule_sets[klass][method][:inputs] = [] unless @rule_sets[klass][method].key? :inputs
    # Set value.
    @rule_sets[klass][method][:inputs][arg_num] = rule_set
  end

  ##
  # Set output aggregated rule set.
  #
  # @param klass [Symbol]
  # @param method [Symbol]
  # @param rule_set [RuleSet]
  ##
  def set_output_rule_set(klass, method, rule_set)
    # Set defaults.
    @rule_sets[klass] = {} unless @rule_sets.key? klass
    @rule_sets[klass][method] = {} unless @rule_sets[klass].key? method
    # Set value.
    @rule_sets[klass][method][:output] = rule_set
  end

  ##
  # Create aggregated rule sets.
  #
  # @param klass [Symbol]
  # @param method [Symbol]
  # @param controls [Array]
  ##
  def load(controls)

    # Create aggregated rule sets for each control's inputs/output.
    controls.each do |control|

      # Process inputs.
      control[:inputs].each_with_index do |input, arg_num|
        rule_set = get_input_rule_set(klass, method, arg_num)
        if rule_set.nil?
          rule_set = RuleSet.new()
          set_input_rule_set(klass, method, arg_num, rule_set)
        end
        rule_set.load(input[:type], input[:value])
      end

      # Process output.
      output_rule_set = get_output_rule_set(klass, method)
      if output_rule_set.nil?
        output_rule_set = RuleSet.new()
        set_output_rule_set(klass, method, output_rule_set)
      end
      output_rule_set.load(control[:output][:type], control[:output][:value])

    end

  end

  ##
  # Train RuleSets from controls.
  #
  # @param klass [Symbol]
  # @param method [Symbol]
  ##
  def train(klass, method)

    input_rule_sets = get_input_rule_sets(klass, method)
    unless input_rule_sets.nil?
      input_rule_sets.each do |input_rule_set|
        input_rule_set.train()
      end
    end

    output_rule_set = get_output_rule_set(klass, method)
    unless output_rule_set.nil?
      output_rule_set.train()
    end

  end

  ##
  # Validate inputs.
  #
  # @param inputs [Array] The method's arguments.
  # @param input_rule_sets [Array] The RuleSets to validate each input with.
  ##
  def validate_inputs(inputs, input_rule_sets)

    # Default to a PASS result.
    result = true

    # Validate each argument against each rule set for that argument.
    inputs.each_with_index do |input, arg_num|

      unless input_rule_sets[arg_num].nil?

        rule_set = input_rule_sets[arg_num]

        unless rule_set.validate_rule(input)
          result = false
        end

      end
    end

    return result

  end

  ##
  # Validate output.
  #
  # @param output [Dynamic] The method's return value.
  # @param output_rule_set [RuleSet] The rule set to validate the output with.
  ##
  def validate_output(output, output_rule_set)

    # Default to a PASS result.
    result = true

    unless output_rule_set.nil?

      # Validate output RuleSet for that argument.
      unless output_rule_set.validate_rule(output)
        result = false
      end

    end

    return result

  end

end
