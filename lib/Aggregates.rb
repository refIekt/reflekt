################################################################################
# RULER
#
# Aggregates input/output from controls.
# Creates and trains RuleSets from aggregated input/output.
# Validates reflection input/output against RuleSets.
################################################################################

require 'RuleSet'

class Aggregates

  def initialize()
    @rule_sets = {}
  end

  ##
  # Get input RuleSets.
  #
  # @param Symbol klass
  # @param Symbol method
  #
  # @return Array
  ##
  def get_input_rule_sets(klass, method)
    return @rule_sets.dig(klass, method, :inputs)
  end

  ##
  # Get input RuleSet.
  #
  # @param Symbol klass
  # @param Symbol method
  #
  # @return RuleSet
  ##
  def get_input_rule_set(klass, method, arg_num)
    @rule_sets.dig(klass, method, :inputs, arg_num)
  end

  ##
  # Get output RuleSet.
  #
  # @param Symbol klass
  # @param Symbol method
  #
  # @return RuleSet.
  ##
  def get_output_rule_set(klass, method)
    @rule_sets.dig(klass, method, :output)
  end

  ##
  # Set input RuleSet.
  #
  # @param Symbol klass
  # @param Symbol method
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
  # Set output RuleSet.
  #
  # @param Symbol klass
  # @param Symbol method
  # @param RuleSet rule_set
  ##
  def set_output_rule_set(klass, method, rule_set)
    # Set defaults.
    @rule_sets[klass] = {} unless @rule_sets.key? klass
    @rule_sets[klass][method] = {} unless @rule_sets[klass].key? method
    # Set value.
    @rule_sets[klass][method][:output] = rule_set
  end

  ##
  # Load RuleSets.
  #
  # @param Symbol klass
  # @param Symbol method
  # @param Array controls
  ##
  def load(klass, method, controls)

    # Create a RuleSet for each control's inputs/output.
    controls.each_with_index do |control, index|

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
  # @param Symbol klass
  # @param Symbol method
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
  # @param Array inputs - The method's arguments.
  # @param Array input_rule_sets - The RuleSets to validate each input with.
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
  # @param dynamic output - The method's return value.
  # @param RuleSet output_rule_set - The RuleSet to validate the output with.
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
