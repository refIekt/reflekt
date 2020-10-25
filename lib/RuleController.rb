################################################################################
# Creates rule sets.
#
# Hierachy:
# 1. RuleController
# 2. RuleSet
# 3. Rule
################################################################################

require 'RuleSet'

class RuleController

  ##
  # Create a rule set for each argument.
  #
  # @param args [Dynamic] The arguments to create rule sets for.
  ##
  def self.create_rule_sets(args)

    rule_sets = []

    args.each do |arg|
      rule_set = RuleSet.new()
      rule_set.create_rules(arg)
      rule_sets << rule_set.result()
    end

    return rule_sets

  end

  ##
  # Create a rule set for each argument.
  #
  # @param args [Dynamic] The arguments to create rule sets for.
  ##
  def self.create_rule_set(arg)

    rule_set = RuleSet.new()
    rule_set.create_rules(arg)

    return rule_set.result()

  end

  #def validate_rule(value)
  #  result = true

  #  @rules.each do |klass, rule|

  #    unless rule.validate(value)
  #      result = false
  #    end
  #  end

  #  return result
  #end

end
