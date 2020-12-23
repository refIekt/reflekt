################################################################################
# A shadow action.
#
# @hierachy
#   1. Action <- YOU ARE HERE
#   2. Reflection
#   3. Meta
################################################################################

class Action

  attr_accessor :unique_id
  attr_accessor :caller_object
  attr_accessor :caller_id
  attr_accessor :caller_class
  attr_accessor :klass
  attr_accessor :method
  attr_accessor :base
  attr_accessor :parent
  attr_accessor :child
  attr_accessor :control
  attr_accessor :experiments
  attr_accessor :is_reflecting
  attr_accessor :is_base

  ##
  # Create Action.
  #
  # @param object [Object] The calling object.
  # @param method [Symbol] The calling method.
  # @param reflect_amount [Integer] The number of experiments to create per action.
  # @param stack [ActionStack] The shadow action call stack.
  ##
  def initialize(caller_object, method, reflect_amount, stack)

    @time = Time.now.to_i
    @unique_id = @time + rand(1..99999)
    @base = nil
    @parent = nil
    @child = nil

    # Dependency.
    @stack = stack

    # Caller.
    @caller_object = caller_object
    @caller_id = caller_object.object_id
    @caller_class = caller_object.class
    @klass = @caller_class.to_s.to_sym
    @method = method

    # Reflections.
    @control = nil
    @experiments = Array.new(reflect_amount)

    # State.
    if @stack.peek() == nil
      @is_base = true
    else
      @is_base = false
      @base = @stack.base()
    end
    @is_reflecting = false

  end

  def has_empty_experiments?
    @experiments.include? nil
  end

  ##
  # Is the Action currently reflecting methods?
  ##
  def is_reflecting?
    @is_reflecting
  end

  def has_finished_reflecting?
    if is_reflecting?
      return false
    end
    if has_empty_experiments?
      return false
    end
    return true
  end

end
