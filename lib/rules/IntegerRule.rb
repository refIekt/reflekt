require 'Rule'

class IntegerRule < Rule

  def initialize()

    @min = nil
    @max = nil

  end

  def train(value)

    if @min.nil?
      @min = value
    else
      @min = value if value < @min
    end

    if @max.nil?
      @max = value
    else
      @max = value if value > @max
    end

  end

  def test(value)

    return false if value < @min
    return false if value > @max

    true
  end

  def result()
    rule = {
      :value => @value
    }
    rule
  end

end
