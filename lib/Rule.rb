################################################################################
# A template for all rules to follow.
#
# @see lib/rules for child rules.
################################################################################

require 'set'

class Rule

  # Each rule intitalises itself.
  def initialize()
    @values = []
  end

  # Each rule trains on values to determine its boundaries.
  def train(arg)

  end

  # Each rule provides a serializable result.
  def result()
    return {}
  end

  # Each rule compares the values it's given with its boundaries.
  def validate(value)

  end

end
