################################################################################
# RULER
#
# Aggregates a method's input/output.
# Creates a pool of rules from each aggregation.
# Validates input/output against rules.
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
  # Returns RuleSet for class/method.
  # Returns empty array when no RuleSets exist for class/method.
  ##
  def get(class_name, method, type)

    # A RuleSet for class/method will not exist the first time the db generated.
    unless @rule_sets.key? class_name.to_s.to_sym
      return []
    end
    @rule_sets[class_name.to_s.to_sym][method.to_s][type]

  end

  def set(execution, method, type, value)
    @rule_sets[execution][method][type] = value
  end

  def process(class_name, method_name, controls)

    input_rule_sets = get(class_name, method_name, :inputs)
    output_rule_set = get(class_name, method_name, :output)

    # Create a RuleSet for each control input/output.
    controls.each_with_index do |control, index|

      process_io(control, INPUTS, input_rule_sets)
      process_io(control, OUTPUT, output_rule_set)

    end

  end

  def process_io(control, io_type, rule_sets)

    # Ensure outputs/input behave as arrays even if they're only one value.
    control_type_ios = control[io_type]
    control_type_ios = [*control_type_ios]

    p control_type_ios

    #control_type_ios.each_with_index do |io, index|

    #  p io

    #  if rule_sets[index].nil?
    #    rule_sets[index] = RuleSet.new()
    #  end

    #  #rule_sets[index].process(io[TYPE], io[VALUE])

    #end

  end

  def train(class_name, method_name)

    inputs = get(class_name, method_name, :inputs)
    inputs.each do |rule_pool|
      unless rule_pool.nil?
        rule_pool.train()
      end
    end

    output = get(execution, method_name, :output)
    unless output.nil?
      output.train()
    end

  end

end
