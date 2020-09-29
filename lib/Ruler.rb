require 'Rule'

class Ruler

  INPUT   = "i"
  OUTPUT  = "o"

  def initialize()

    @input_types = {}
    @output_types = {}

  end

  def train(controls)

    controls.each do |control|

      control[INPUT].each_with_index do |input, index|
        @input_types[index] = input.class
      end

      control[OUTPUT].each_with_index do |output, index|
        @output_types[output] = output.class
      end

    end

  end

end
