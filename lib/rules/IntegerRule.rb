require 'Rule'

class IntegerRule < Rule

  attr_accessor :min
  attr_accessor :max

  def initialize()
    super

    @min = nil
    @max = nil

  end

  def train(value)

    @min = value.min if value.min > @min
    @max = value.max if value.max < @max

  end

  def result()

    {
      :min => @min,
      :max => @max
    }

  end

  def validate(value)

    return false if value < @min
    return false if value > @max

    true
  end

end
