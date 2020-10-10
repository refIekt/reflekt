################################################################################
# RULER
#
# Aggregates a method's input/output.
# Creates a pool of rules from each aggregation.
# Validates input/output against rules.
################################################################################

require 'RuleSet'

class Ruler

  INPUT  = "i"
  OUTPUT = "o"
  TYPE   = "T"
  VALUE  = "V"

  def initialize()
    @rule_sets = {}
  end

  def get(class_name, method, type)
    # The method's ruler will not exist the first time the db generated.
    if @rule_sets.key? class_name.to_s.to_sym
      return @rule_sets[class_name.to_s.to_sym][method.to_s][type]
    end
    nil
  end

  def set(execution, method, type, value)
    @rule_sets[execution][method][type] = value
  end

  def process(class_name, method_name, controls)

    inputs = get(class_name, method_name, :inputs)
    controls.each_with_index do |control, index|

      # Create rule pools for each input.
      control[INPUT].each_with_index do |input, index|
        unless input.nil?

          if inputs[index].nil?
            inputs[index] = RuleSet.new()
          end

          inputs[index].process(input[TYPE], input[VALUE])

        end
      end

      # Create rule pool for the output.
      output = get(class_name, method_name, :output)
      unless control[OUTPUT].nil?

        if output.nil?
          output = RuleSet.new()
        end

        output.process(control[OUTPUT][TYPE], control[OUTPUT][VALUE])

      end

    end

  end

  def train(class_name, method_name)

    inputs = get(class_name, method, :inputs)
    inputs.each do |rule_pool|
      unless rule_pool.nil?
        rule_pool.train()
      end
    end

    output = get(execution, method, :output)
    unless output.nil?
      output.train()
    end

  end

end
