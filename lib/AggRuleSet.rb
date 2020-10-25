################################################################################
# AGG RULE SET
################################################################################

require 'set'

class AggRuleSet

  attr_accessor :types
  attr_accessor :rules

  def initialize()

    @types = Set.new
    @rules = {}

  end

end
