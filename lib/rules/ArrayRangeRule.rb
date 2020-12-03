require 'Rule'

class ArrayRangeRule < Rule

  def initialize()

    @min_length = nil
    @max_length = nil

  end

  ##
  # @param meta [ArrayMeta]
  ##
  def train(meta)

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

    return false if value.length < @min_length
    return false if value.length > @max_length

    true
  end

  def result()
    {
      :type => :array,
      :min_length => @min_length,
      :max_length => @max_length
    }
  end

end
