require 'Rule'

class FloatValue < Value

  attr_accessor :value

  def initialize()

    @value = nil

  end

  def load(value)

    @value = value

  end

  def result()

    result = {
      :value => @value
    }

    return result

  end

end
