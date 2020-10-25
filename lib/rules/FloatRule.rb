require 'Rule'

class FloatRule < Rule

  attr_accessor :min
  attr_accessor :max

  def initialize()
    super

    @min = nil
    @max = nil

  end

  def load(value)
    @values << value.to_i
  end

  def train()
    numbers = @values.select {|num| num.class == Float }
    numbers.sort!
    @min = numbers.first
    @max = numbers.last
  end

  def validate(value)

    return false if value < @min
    return false if value > @max

    true
  end

end
