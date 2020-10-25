################################################################################
# RULE SET
#
# A collection of rules that validate an argument.
################################################################################

require 'set'

class RuleSet

  attr_accessor :types
  attr_accessor :rules

  def initialize()

    @types = Set.new
    @rules = {}

  end

  def create_rules(arg)

    @rules.each do |klass, rule|
      rule.load(arg)
    end

  end

end
