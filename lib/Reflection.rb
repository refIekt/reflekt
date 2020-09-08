class Reflection

  attr_accessor :value
  attr_accessor :execute
  attr_accessor :reflect

  def initialize(value)

    @is_execution = true
    @is_reflection = true

    @value = value
    @execution = nil
    @reflections = nil

  end

end
