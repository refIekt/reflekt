class Execution

  attr_accessor :object
  attr_accessor :caller_id
  attr_accessor :caller_class
  attr_accessor :klass
  attr_accessor :method
  attr_accessor :parent
  attr_accessor :child
  attr_accessor :control
  attr_accessor :reflections
  attr_accessor :is_reflecting

  def initialize(object, method, reflection_count)

    @object = object
    @caller_id = object.object_id
    @caller_class = object.class
    
    @klass = object.class.to_s.to_sym
    @method = method

    @parent = nil
    @child = nil
    @control = nil
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
