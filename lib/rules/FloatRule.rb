require 'Rule'

class FloatRule < Rule

  def initialize()

    @min = nil
    @max = nil

  end

  ##
  # @param meta [FloatMeta]
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
  # @param value [Float]
  ##
  def test(value)

    return false if value < @min
    return false if value > @max

    true
  end

  def result()
    {
      :type => :float,
      :min => @min,
      :max => @max
    }
  end

  def random()
    rand(@min..@max)
  end

end
