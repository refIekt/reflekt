class Execution

  attr_accessor :object
  attr_accessor :executed
  attr_accessor :child
  attr_accessor :reflections

  def initialize(object, reflection_count)

    @object = object
    @object_id = object.object_id
    @child = nil

    @executed = false
    @reflections = Array.new(reflection_count)

  end

  def reflect?
    @reflections.include? nil
  end

  def executed?
    @executed
  end

end
