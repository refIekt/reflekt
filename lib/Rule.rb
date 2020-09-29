require 'set'

class Rule

  attr_accessor :type
  attr_accessor :min
  attr_accessor :max
  attr_accessor :length
  attr_accessor :types
  attr_accessor :values

  def initialize()

    @types = Set.new
    @values = Set.new
    @min = nil
    @max = nil
    @length = nil

  end

  ##
  # A parameter can accept multiple input types.
  # Duplicates will not be added to the set.
  ##
  def add_type(type)
    @types.add(type)
  end

  def add_value(value)
    @values.add(value)
  end

  def is_number?
    @types.include? Integer
  end

end
