################################################################################
# RULES
#
# Abstract class.
# See lib/rules for rules.
################################################################################

require 'set'

class Rule

  # Each rule intitalises itself.
  def initialize()
    @values = nil
  end

  # Each rule loads up an array of values.
  def load(value)
    @values << value
  end

  # Each rule trains on values to determine its patterns.
  def train()

  end

  # Each rule compares the data it has with the data it's given.
  def validate()

  end

end
