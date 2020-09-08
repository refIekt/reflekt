class Execution

  attr_accessor :executed
  attr_accessor :reflections
  attr_accessor :child

  def initialize(object, args, reflection_count)

    @object_id = object.object_id
    @args = args

    @executed = false
    @reflections = Array.new(reflection_count)
    @child = nil

  end

  def reflect?
    @reflections.include? nil
  end

  def executed?
    @executed
  end

end
