require 'Rule'

class StringRule < Rule

  attr_accessor :min_length
  attr_accessor :max_length

  def initialize()

    @min_length = nil
    @max_length = nil

  end

  def train(value)
    # TODO.
  end

  def test(value)
    # TODO.
    true
  end

  def result()
    rule = {
      :value => @value
    }
    rule
  end

end
