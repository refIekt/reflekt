require 'Rule'

class Ruler

  INPUT = "i"
  OUTPUT = "o"

  def initialize()

    @controls = nil
    @inputs = []
    @outputs = []

  end

  def load(controls)

    @controls = controls
    @controls.each do |control|

      control[INPUT].each_with_index do |input, index|
        if @inputs[index].nil?
          rule = Rule.new()
          @inputs[index] = rule
        else
          rule = @inputs[index]
        end
        rule.add_type(input.class)
        rule.add_value(input)
      end

      control[OUTPUT].each_with_index do |output, index|
        if @outputs[index].nil?
          rule = Rule.new()
          @outputs[index] = rule
        else
          rule = @outputs[index]
        end
        rule.add_type(output.class)
        rule.add_value(output)
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

  def accept(klass, method)
    return true
  end

end
