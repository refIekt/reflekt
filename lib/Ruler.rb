################################################################################
# RULER
#
# Manages rule sets.
################################################################################

require 'RuleSet'

class Ruler

  ##
  # Create a RuleSet for each argument.
  #
  # @param args [Dynamic] The arguments to create rule sets for.
  ##
  def self.create_rule_set(args)

    rule_sets = []

    args.each do |arg|

      rule_set = RuleSet.new()
      rule_set.load(input[:type], input[:value])

    end

    return rule_sets

  end

end
