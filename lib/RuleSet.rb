################################################################################
# A collection of rules that validate a value.
#
# @patterns
#   [Dependency Injection, Builder]
#
# @hierachy
#   1. Aggregator
#   2. RuleSet <- YOU ARE HERE.
#   3. Rule
################################################################################

require 'set'

class RuleSet

  attr_accessor :rules

  ##
  # @param rule_map [Hash] The rules to apply to each data type.
  ##
  def initialize(rule_map)

    @rule_map = rule_map
    @rules = {}
    @types = Set.new()

  end

  ##
  # Train rule set on metadata.
  #
  # @param meta [Meta] The metadata to train on.
  ##
  def train(meta)

    # Track data type.
    @types << meta.class
    meta_type = meta.class

    # Get rules for this meta type.
    if @rule_map.key? meta_type

      @rule_map[meta_type].each do |rule_type|

        # Ensure rules exist for this meta type.
        if @rules[rule_type].nil?
          @rules << rule_type.new()
        end

        # Train rules for this type.
        @rules[rule_type].train(meta)

      end

    end

    return self

  end

  ##
  # Get the results of the rules.
  #
  # @return [Array] The rules.
  ##
  def result()

    rules = {}

    @rules.each do |key, rule|
      rules[rule.class] = rule.result()
    end

    return rules

  end

end
