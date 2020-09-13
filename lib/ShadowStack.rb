################################################################################
# SHADOW STACK
#
# Track the executions in a call stack.
################################################################################

class ShadowStack

  def initialize()
    @bottom = nil
    @top = nil
  end

  def peek()
    @top
  end

  def base()
    @bottom
  end

  ##
  # Push Execution.
  #
  # @param object - The object being executed.
  # @param args - The arguments being executed.
  #
  # @return Execution - The new execution.
  ##
  def push(object, reflection_count)

    # Create execution.
    execution = Execution.new(object, reflection_count)

    # Reference previous execution.
    if @bottom.nil?
      @bottom = execution
    else
      @top.child = execution
    end

    # Place new execution at the top of the stack.
    @top = execution

  end

  def display
    display_execution_tree(@bottom)
  end

  def display_execution_tree(execution)
    p execution
    unless execution.child == nil
      display_execution_tree(execution.child)
    end
  end

end
