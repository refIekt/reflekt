################################################################################
# A reprsentation of a null value.
#
# @hierachy
#   1. Action
#   2. Reflection
#   3. Meta <- YOU ARE HERE
################################################################################

require_relative '../meta'

module Reflekt
  class ObjectMeta < Meta

    def initialize()
      @type = :object
      @class_type = nil
    end

    ##
    # @param value [Dynamic] Any custom class.
    ##
    def load(value)
      @class_type = value.class
    end

    def serialize()
      {
        :type => @type,
        :class_type => @class_type
      }
    end

  end
end
