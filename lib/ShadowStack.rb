################################################################################
# Track the executions in a shadow call stack.
#
# @pattern Stack
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
  # Place Action at the top of stack.
  #
  # @param execution [Action] The execution to place.
  # @return [Action] The placed execution.
  ##
  def push(execution)

    # Place first execution at bottom of stack.
    if @bottom.nil?
      @bottom = execution
    # Connect subsequent executions to each other.
    else
      @top.parent = execution
      execution.child = @top
    end

    # Place execution at top of stack.
    @top = execution

  end

end
