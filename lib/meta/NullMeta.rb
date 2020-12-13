################################################################################
# A reprsentation of a null value.
#
# @note
#   A "null" value on serialized "inputs" and "output" also becomes a NullMeta.
#
# @hierachy
#   1. Action
#   2. Reflection
#   3. Meta <- YOU ARE HERE
################################################################################

require 'Meta'

class NullMeta < Meta

  def initialize()
    @type = :null
  end

  ##
  # @param value [NilClass]
  ##
  def load(value)
    # No need to load a value for null meta.
  end

  def serialize()
    {
      :type => @type,
    }
  end

end
