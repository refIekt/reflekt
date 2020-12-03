################################################################################
# A pattern that metadata follows.
#
# @pattern Abstract class
#
# @hierachy
#   1. Aggregator
#   2. RuleSet
#   3. Rule <- YOU ARE HERE
#
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
  # Each rule provides results.
  #
  # @return [Hash]
  ##
  def result()
    {}
  end

  ##
  # Each rule provides a random example that matches the rule's boundaries.
  #
  # @return [Dynamic] A random value.
  ##
  def random()
  end

end
