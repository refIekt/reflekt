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

  def random()

    # Build alphabet soup.
    alpha_numeric = Array('A'..'Z') + Array('a'..'z')
    10.times do
      alpha_numeric << ' '
    end

    # Dip ladle into alphabet soup.
    last_char = nil
    string = Array.new(rand(@min_length..@max_length)) do |index|
      char = alpha_numeric.sample
      while char == last_char
        char = alpha_numeric.sample
      end
      last_char = char
      return char
    end

    return string.join

  end

end
