################################################################################
# All rules behave the same.
#
# @pattern Abstract class.
# @see lib/rules for rules.
################################################################################

class Rule

  ##
  # Each rule trains on metadata to determine its boundaries.
  #
  # @param meta [Meta]
  ##
  def train(meta)
  end

  ##
  # Each rule validates a value with its boundaries.
  #
  # @param value [Dynamic]
  # @return [Boolean] Whether the value passes or fails.
  ##
  def test(value)
  end

  ##
  # Each rule provides metadata.
  #
  # @return [Hash]
  ##
  def result()
    {}
  end

end
