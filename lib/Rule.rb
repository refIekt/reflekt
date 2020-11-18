################################################################################
# All rules behave the same.
#
# @pattern Abstract class.
# @see lib/rules for rules.
################################################################################

require 'set'

class Rule

  ##
  # Each rule intitalises itself.
  ##
  def initialize()
    @values = []
  end

  ##
  # Each rule trains on a value to determine its boundaries.
  ##
  def train(value)
  end

  ##
  # Each rule validates a value with its boundaries.
  # @return [Boolean]
  ##
  def test(value)
  end

  ##
  # Each rule provides metadata.
  # @return [Hash]
  ##
  def result()
    rule = {}
    rule
  end

end
