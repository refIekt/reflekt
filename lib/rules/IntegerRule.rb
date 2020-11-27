require 'Rule'

class IntegerRule < Rule

  def initialize()

    @min = nil
    @max = nil

  end

  ##
  # @param meta [IntegerMeta]
  ##
  def train(meta)

    value = meta[:value]

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

  ##
  # @param value [Integer]
  ##
  def test(value)

    return false if value < @min
    return false if value > @max

    true
  end

  def result()
    {
      :type => :int,
      :min => @min,
      :max => @max
    }
  end

end
