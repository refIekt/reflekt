require 'Rule'

class ArrayRule < Rule

  def initialize()

    @min = nil
    @max = nil

  end

  ##
  # @param meta [ArrayMeta]
  ##
  def train(meta)

    # Min value.
    if @min.nil?
      @min = meta[:min]
    else
      @min = meta[:min] if meta[:min] < @min
    end

    # Max value.
    if @max.nil?
      @max = meta[:max]
    else
      @max = meta[:max] if meta[:max] > @max
    end

  end

  ##
  # @param value [Array]
  ##
  def test(value)

    return false if value.min() < @min
    return false if value.max() > @max

    true
  end

  def result()
    {
      :type => :array,
      :min => @min,
      :max => @max
    }
  end

end
