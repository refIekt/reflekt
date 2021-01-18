require_relative '../rule'

module Reflekt
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

    if Meta.numeric? meta[:min]

      # Min value.
      meta_min = meta[:min].to_i
      if @min.nil?
        @min = meta_min
      else
        @min = meta_min if meta_min < @min
      end

      # Max value.
      meta_max = meta[:max].to_i
      if @max.nil?
        @max = meta_max
      else
        @max = meta_max if meta_max > @max
      end

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

    # Empty value.
    # Fixes: NoMethodError: undefined method `<' for nil:NilClass
    return true if value.empty? && @min_length == 0 && @max_length == 0

    unless value.empty?

      # Numbers only; if the value is a string then there will be no min/max.
      unless @min.nil? || @max.nil?
        return false if value.min() < @min
        return false if value.max() > @max
      end

      p value

      # Min/max length.
      return false if value.length < @min_length
      return false if value.length > @max_length

    end

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
end
