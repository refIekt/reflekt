require 'Rule'

class AggIntegerRule < Rule

  def initialize()
    super

    @min = nil
    @max = nil

  end

  def train(integer_rule)

    @min = integer_rule.min if integer_rule.min > @min
    @max = integer_rule.max if integer_rule.max < @max

  end

  def validate(value)

    return false if value < @min
    return false if value > @max

    true
  end

end
