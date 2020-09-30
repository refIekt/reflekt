require 'Rule'

class Ruler

  INPUT  = "i"
  OUTPUT = "o"
  TYPE   = "T"
  VALUE  = "V"

  def initialize()

    @controls = nil
    @inputs = []
    @outputs = []

  end

  def load(controls)

    @controls = controls
    @controls.each do |control_key, control|

      # TODO: Figure out why timestamp, "p" and "nil" items leaking through.
      unless control.class == Hash
        next
      end

      unless control[INPUT].nil? || control[INPUT].empty?
        control[INPUT].each_with_index do |input, index|

          # Create rule.
          if @inputs[index].nil?
            rule = Rule.new()
            @inputs[index] = rule
          else
            rule = @inputs[index]
          end

          # Add rules to rule.
          unless input[TYPE].nil? || input[TYPE].empty?
            rule.add_type(input[TYPE])
          end
          unless input[VALUE].nil? || input[VALUE].empty?
            rule.add_value(input[VALUE])
          end

        end
      end

      unless control[OUTPUT].nil? || control[OUTPUT].empty?
        control[OUTPUT].each_with_index do |output, index|

          # Create rule.
          if @outputs[index].nil?
            rule = Rule.new()
            @outputs[index] = rule
          else
            rule = @outputs[index]
          end

          # Add rules to rule.
          unless output[TYPE].nil? || output[TYPE].empty?
            rule.add_type(output[TYPE])
          end
          unless output[VALUE].nil? || output[VALUE].empty?
            rule.add_value(output[VALUE])
          end

        end
      end

    end

  end

  def train()

    @inputs.each do |rule|
      # Get min/max.
      if rule.is_number?
        numbers = rule.values.select {|num| num.class == Integer }
        numbers.sort!
        rule.min = numbers.first
        rule.max = numbers.last
      end

    end

  end

  def validate_input(klass, method, inputs)
    result = true
    inputs.each_with_index do |value, index|
      rule = @inputs[index]
      if rule.is_number? && value.class == Integer
        result = false if value < rule.min
        result = false if value > rule.max
      end
    end
    return result
  end

  def validate_output(klass, method, outputs)
    result = true
    outputs.each_with_index do |value, index|
      rule = @outputs[index]
      if rule.is_number? && value.class == Integer
        result = false if value < rule.min
        result = false if value > rule.max
      end
    end
    return result
  end

end
