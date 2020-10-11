################################################################################
# RULER
#
# Aggregates input/output from controls.
# Creates and trains RuleSets from aggregated input/output.
# Validates reflection input/output against RuleSets.
################################################################################

require 'RuleSet'

class Ruler

  INPUTS = "i"
  OUTPUT = "o"
  TYPE   = "T"
  VALUE  = "V"

  def initialize()
    @rule_sets = {}
  end

  ##
  # Get input RuleSets.
  #
  # @return Array
  ##
  def get_input_rule_sets(class_name, method_name)
    @rule_sets.dig(class_name, method_name, :inputs)
  end

  ##
  # Get input RuleSet.
  #
  # @return RuleSet
  ##
  def get_input_rule_set(class_name, method_name, arg_num)
    @rule_sets.dig(class_name, method_name, :inputs, arg_num)
  end

  ##
  # Get output RuleSet.
  #
  # @return RuleSet.
  ##
  def get_output_rule_set(class_name, method_name)
    @rule_sets.dig(class_name, method_name, :output)
  end

  ##
  # Set input RuleSet.
  ##
  def set_input_rule_set(class_name, method_name, arg_num, rule_set)
    # Set defaults.
    @rule_sets[class_name] = {} unless @rule_sets.key? class_name
    @rule_sets[class_name][method_name] = {} unless @rule_sets[class_name].key? method_name
    @rule_sets[class_name][method_name][:inputs] = [] unless @rule_sets[class_name][method_name].key? :inputs
    # Set value.
    @rule_sets[class_name][method_name][:inputs][arg_num] = rule_set
  end

  ##
  # Set output RuleSet.
  ##
  def set_output_rule_set(class_name, method_name, rule_set)
    # Set defaults.
    @rule_sets[class_name] = {} unless @rule_sets.key? class_name
    @rule_sets[class_name][method_name] = {} unless @rule_sets[class_name].key? method_name
    # Set value.
    @rule_sets[class_name][method_name][:output] = rule_set
  end

  ##
  # Load RuleSets.
  ##
  def load(class_name, method_name, controls)

    # Create a RuleSet for each control's inputs/output.
    controls.each_with_index do |control, index|

      # Process inputs.
      control[INPUTS].each_with_index do |input, arg_num|
        rule_set = get_input_rule_set(class_name, method_name, arg_num)
        if rule_set.nil?
          rule_set = RuleSet.new()
          set_input_rule_set(class_name, method_name, arg_num, rule_set)
        end
        rule_set.load(input[TYPE], input[VALUE])
      end

      # Process output.
      output_rule_set = get_output_rule_set(class_name, method_name)
      if output_rule_set.nil?
        output_rule_set = RuleSet.new()
        set_output_rule_set(class_name, method_name, output_rule_set)
      end
      output_rule_set.load(control[OUTPUT][TYPE], control[OUTPUT][VALUE])

    end

  end

  ##
  # Train RuleSets from controls.
  ##
  def train(class_name, method_name)

    input_rule_sets = get_input_rule_sets(class_name, method_name)
    unless input_rule_sets.nil?
      input_rule_sets.each do |input_rule_set|
        input_rule_set.train()
      end
    end

    output_rule_set = get_output_rule_set(class_name, method_name)
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

      rule_set = input_rule_sets[arg_num]

      # Can't validate an empty rule set.
      if rule_set.empty?
        next
      end

      unless rule_set.validate(input)
        result = false
      end
    end

    return result

  end

  ##
  # Validate output.
  #
  # @param output - The method's return value.
  # @param RuleSet output_rule_set - The RuleSet to validate the output with.
  ##
  def validate_output(output, output_rule_set)

    # Default to a PASS result.
    result = true

    # Can't validate an empty rule pool.
    if rule_set.empty?
      return result
    end

    # Validate output RuleSet for that argument.
    unless output_rule_set.validate(output)
      result = false
    end

    return result

  end

end
