################################################################################
# A clone of the instance that a reflection calls methods on,
# as well as any other instances that those methods may lead to.
#
# @note
#   Not currently in use due to bug where "send" needs to be called directly
#   on object, not indirectly through clone which results in "undefined method".
#
# @hierachy
#   1. Action
#   2. Reflection
#   3. Clone <- YOU ARE HERE
################################################################################

module Reflekt
  class Clone
    def initialize(action)
      # Clone the action's calling object.
      @caller_object_clone = action.caller_object.clone

      # TODO: Clone any other instances that this clone references.
      # TODO: Replace clone's references to these new instances.
    end

    def action(method, *new_args)
      @caller_object_clone.send(method, *new_args)
    end
  end
end
