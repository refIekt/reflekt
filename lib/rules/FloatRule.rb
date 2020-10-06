class FloatRule < Rule

  attr_accessor :min
  attr_accessor :max

  def initialize()
    @min = nil
    @max = nil
  end

  def load(value)
    @values << value
  end

  def train()
    # TODO.
  end

  def validate()
    # TODO.
    true
  end

end
