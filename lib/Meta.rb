################################################################################
# Metadata for input and output.
#
# @pattern Abstract class
#
# @see lib/meta for each meta.
#
# @hierachy
#   1. Execution
#   2. Reflection
#   3. Meta <- YOU ARE HERE
################################################################################

class Meta

  ##
  # Each meta loads values.
  #
  # @param value [Dynamic]
  ##
  def load(value)
  end

  ##
  # Each meta provides metadata.
  #
  # @return [Hash]
  ##
  def result()
    {}
  end

end
