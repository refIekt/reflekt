require 'Rule'

class StringRule < Rule

  attr_accessor :min_length
  attr_accessor :max_length

  def initialize()

    @min_length = nil
    @max_length = nil

  end

  ##
  # @param meta [StringMeta]
  ##
  def train(meta)

    length = meta[:length]

    if @min_length.nil?
      @min_length = length
    else
      @min_length = length if length < @min_length
    end

    if @max_length.nil?
      @max_length = length
    else
      @max_length = length if length > @max_length
    end

  end

  ##
  # @param value [String]
  ##
  def test(value)

    length = value.length

    return false if length < @min_length
    return false if length > @max_length

    true
  end

  def result()
    {
      :type => :string,
      :min_length => @min_length,
      :max_length => @max_length
    }
  end

end
