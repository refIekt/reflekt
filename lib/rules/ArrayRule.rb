require 'rule'

class ArrayRule < Rule

  def initialize()

    @type = :array
    @min = nil
    @max = nil
    @min_length = nil
    @max_length = nil

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

    # Min length.
    if @min_length.nil?
      @min_length = meta[:length]
    else
      @min_length = meta[:length] if meta[:length] < @min_length
    end

    # Max length.
    if @max_length.nil?
      @max_length = meta[:length]
    else
      @max_length = meta[:length] if meta[:length] > @max_length
    end

  end

  ##
  # @param value [Array]
  ##
  def test(value)

    # Min/max value.
    return false if value.min() < @min
    return false if value.max() > @max

    # Min/max length.
    return false if value.length < @min_length
    return false if value.length > @max_length

    true
  end

  def result()
    {
      :type => @type,
      :min => @min,
      :max => @max,
      :min_length => @min_length,
      :max_length => @max_length
    }
  end

  def random()

    array = Array.new(rand(@min_length..@max_length))

    array.each_with_index do |item, index|
      array[index] = rand(@min..@max)
    end

    return array

  end

end
