require 'Rule'

class IntegerRule < Rule

  attr_accessor :min
  attr_accessor :max

  def initialize()
    super

    @min = nil
    @max = nil
  end

  def load(value)
    @values << value
  end

  def train()
    numbers = @values.select {|num| num.class == Integer }
    numbers.sort!
    @min = numbers.first
    @max = numbers.last
  end

  def validate()
    return false if value < rule.min
    return false if value > rule.max
  end

end
