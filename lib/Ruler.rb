################################################################################
# RULER
#
# Aggregates control input/output.
# Creates and trains RuleSets from aggregates.
# Validates reflection input/output against RuleSets.
################################################################################

require 'RuleSet'

class Ruler

  INPUTS  = "i"
  OUTPUT = "o"
  TYPE   = "T"
  VALUE  = "V"

  def initialize()
    @rule_sets = {}
  end

  ##
  # Get RuleSet for class/method.
  #
  # Returns empty array when no RuleSets exist for class/method.
  ##
  def get(class_name, method, type)

    # A RuleSet for class/method will not exist the first time the db generated.
    unless @rule_sets.key? class_name.to_s.to_sym
      return []
    end
    @rule_sets[class_name.to_s.to_sym][method.to_s][type]

  end

  ##
  # Set RuleSet.
  ##
  def set(execution, method, type, value)
    @rule_sets[execution][method][type] = value
  end

  ##
  # Create RuleSets.
  ##
  def create(class_name, method_name, controls)

    input_rule_sets = get(class_name, method_name, :inputs)
    output_rule_set = get(class_name, method_name, :output)

    # Create a RuleSet for each control input/output.
    controls.each_with_index do |control, index|
      process_io(control, INPUTS, input_rule_sets)
      process_io(control, OUTPUT, output_rule_set)
    end

  end

  def process_io(control, io_type, rule_sets)

    control_type_ios = control[io_type]

    # Ensure inputs and output are inside arrays even if they're only one value.
    if control[io_type].class == Hash
      control_type_ios = [control_type_ios]
    end

    # Generate RuleSets for inputs/outputs.
    control_type_ios.each_with_index do |io, index|
      if rule_sets[index].nil?
        rule_sets[index] = RuleSet.new()
      end
      rule_sets[index].process(io[TYPE], io[VALUE])
    end

  end

  ##
  # Train RuleSets from controls.
  ##
  def train(class_name, method_name)

    input_rule_sets = get(class_name, method_name, :inputs)
    input_rule_sets.each do |rule_set|
      rule_set.train()
    end

    output_rule_set = get(class_name, method_name, :output)
    output_rule_set.each do |rule_set|
      rule_set.train()
    end

  end

end
