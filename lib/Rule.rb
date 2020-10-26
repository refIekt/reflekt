################################################################################
# RULE
#
# Abstract class.
# @see lib/rules for rules.
################################################################################

require 'set'

class Rule

  # Each rule intitalises itself.
  def initialize()
    @values = []
  end

  # Each rule loads up an array of values.
  def load(value)
    @values << value
  end

  # Each rule trains on values to determine its boundaries.
  def train()

  end

  # Each rule compares the values it's given with its boundaries.
  def validate(value)

  end

end
