require 'Rule'

class IntegerRule < Rule

  def initialize()
    @min = nil
    @max = nil

    super
  end

  def load(value)
    @values << value.to_i
  end

  def train()
    numbers = @values.select {|num| num.class == Integer }
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
