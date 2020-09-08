class ReflectionTree

  def initialize(reflection_count)
    @reflection_count = reflection_count
    @root_execution = nil
    @last_execution = nil
  end

  def get_execution(object, args)
    if @root_execution.nil?
      return add_execution(object, args)
    else
      return @last_execution
    end
  end

  ##
  # Add Execution.
  #
  # @param object - The object being executed.
  # @param args - The arguments being executed.
  #
  # @return Execution - The new execution.
  ##
  def add_execution(object, args)

    # Create execution.
    execution = Execution.new(object, args, @reflection_count)

    # Reference previous execution.
    if @root_execution.nil?
      @root_execution = execution
    else
      @last_execution.child = execution
    end

    # Set new execution as the last execution.
    @last_execution = execution

  end

  def display
    display_execution_tree(@root_execution)
  end

  def display_execution_tree(execution)
    p execution
    unless execution.child == nil
      display_execution_tree(execution.child)
    end
  end

end
