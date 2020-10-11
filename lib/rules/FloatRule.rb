require 'Rule'

class FloatRule < Rule

  attr_accessor :min
  attr_accessor :max

  def initialize()
    super

    @min = nil
    @max = nil
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
