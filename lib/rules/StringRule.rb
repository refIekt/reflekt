require 'Rule'

class StringRule < Rule

  attr_accessor :min_length
  attr_accessor :max_length

  def initialize()
    super

    @min_length = nil
    @max_length = nil

  end

  def load(value)
    @values << value
  end

  def train()
    # TODO.
  end

  def validate(value)
    # TODO.
    true
  end

end
