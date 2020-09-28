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
  def push(execution)

    # Reference previous execution.
    if @bottom.nil?
      @bottom = execution
    else
      execution.child = @top
      @top.parent = execution
    end

    # Place new execution at the top of the stack.
    @top = execution

  end

  def display
    display_execution_tree(@bottom)
  end

  def display_execution_tree(execution)
    p execution
    unless execution.parent == nil
      display_execution_tree(execution.parent)
    end
  end

end
