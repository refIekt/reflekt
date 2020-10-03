require 'Rule'

class Ruler

  INPUT  = "i"
  OUTPUT = "o"
  TYPE   = "T"
  VALUE  = "V"

  def initialize()

    @controls = nil

    # Rules.
    @inputs = []
    @output = nil

  end

  def load(controls)

    @controls = controls
    @controls.each_with_index do |control, index|

      # Multiple inputs.
      control[INPUT].each_with_index do |input, index|
        unless input.nil?

          # Create rule.
          if @inputs[index].nil?
            rule = Rule.new()
            @inputs[index] = rule
          else
            rule = @inputs[index]
          end

          # Add rules to rule.
          unless input[TYPE].nil? || input[TYPE].empty?
            rule.add_type(input[TYPE].class)
          end
          unless input[VALUE].nil? || input[VALUE].empty?
            rule.add_value(input[VALUE])
          end

          index = index + 1
        end
      end

      # Singular output.
      output = control[OUTPUT]
      unless control[OUTPUT].nil?

        # Create rule.
        if @output.nil?
          rule = Rule.new()
          @output = rule
        else
          rule = @output
        end

        ## Add rules to rule.
        unless output[TYPE].nil? || output[TYPE].empty?
          rule.add_type(output[TYPE])
        end
        unless output[VALUE].nil? || output[VALUE].empty?
          rule.add_value(output[VALUE])
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

  def validate_inputs(klass, method, inputs)
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
    rule = @output
    if rule.is_number? && value.class == Integer
      result = false if value < rule.min
      result = false if value > rule.max
    end
    return result
  end

end
