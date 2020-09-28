class Execution

  attr_accessor :object
  attr_accessor :caller_id
  attr_accessor :parent
  attr_accessor :child
  attr_accessor :reflections
  attr_accessor :is_reflecting

  def initialize(object, reflection_count)

    @object = object
    @caller_id = object.object_id
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
    if is_reflecting?
      return false
    end
    if has_empty_reflections?
      return false
    end
    return true
  end

end
