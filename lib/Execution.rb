class Execution

  attr_accessor :object
  attr_accessor :parent
  attr_accessor :child
  attr_accessor :reflections
  attr_accessor :is_reflecting

  def initialize(object, reflection_count)

    @object = object
    @object_id = object.object_id
    @parent = nil
    @child = nil

    @reflections = Array.new(reflection_count)
    @is_reflecting = false

  end

  def has_empty_reflections?
    @reflections.include? nil
  end

  ##
  # Is the Execution currently reflecting methods?
  ##
  def is_reflecting?
    @is_reflecting
  end

  def has_finished_reflecting?
    if has_empty_reflections?
      return false
    end
    return true
  end

end
