################################################################################
# RULE POOL
#
# A collection of rules generated for an argument.
# Duplicates will not be added to the sets.
################################################################################

require 'set'
require 'Rule'

class RulePool

  attr_accessor :types
  attr_accessor :rules

  def initialize()

    @types = Set.new
    @rules = {}

  end

  def train()

    rules.each do |rule|
      rule.train()
    end

  end

  def validate(value)
    result = true

    rules.each do |rule|
      result = rule.validate(value)
      if result == false
        result = false
      end
    end

    return result
  end

end
