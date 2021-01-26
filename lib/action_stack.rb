################################################################################
# Track the actions in a shadow call stack.
#
# @pattern Stack
################################################################################

module Reflekt
  class ActionStack

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
    # @param action [Action] The action to place.
    # @return [Action] The placed action.
    ##
    def push(action)

      # Place first action at bottom of stack.
      if @bottom.nil?
        @bottom = action
      # Connect subsequent actions to each other.
      else
        @top.parent = action
        action.child = @top
      end

      # Place action at top of stack.
      @top = action

    end

  end
end
