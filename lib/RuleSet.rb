################################################################################
# A collection of rules that validate a value.
################################################################################

require 'set'

class RuleSet

  attr_accessor :rules

  def initialize()

    @rules = {}
    @types = Set.new()

  end

  def self.create_sets(args)

    rule_sets = []

    args.each do |arg|
      rule_sets << self.create_set(arg)
    end

    rule_sets
  end

  def self.create_set(value)

    rule_set = RuleSet.new()
    value_type = value.class.to_s

    # Creates values for matching data type.
    case value_type
    when "Integer"
      rule = IntegerRule.new()
      rule.train(arg)
      rule_set.rules[IntegerRule] = rule
    when "String"
      rule = StringRule.new()
      rule.train(arg)
      rule_set.rules[StringRule] = rule
    end

    rule_set
  end

  ##
  # Train rule set on metadata.
  #
  # @param meta [Meta] The metadata to train on.
  ##
  def train(meta)

    # Track data type.
    @types << meta.class
    type = meta.class.to_s

    # Get rule for this data type.
    rule = nil
    case type
    when "Integer"
      unless @rules.key? IntegerRule
        rule = IntegerRule.new()
        @rules[IntegerRule] = rule
      else
        rule = @rules[IntegerRule]
      end
    when "String"
      unless @rules.key? StringRule
        rule = StringRule.new()
        @rules[StringRule] = rule
      else
        rule = @rules[IntegerRule]
      end
    end

    # Train rule.
    unless rule.nil?
      rule.train(meta)
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
