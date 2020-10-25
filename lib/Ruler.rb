################################################################################
# RULER
#
# Manages rule sets.
#
# Hierachy:
# 1. Ruler <- YOU ARE HERE.
# 2. RuleSet
# 3. Rule
################################################################################

require 'RuleSet'

class Ruler

  ##
  # Create a RuleSet for each argument.
  #
  # @param args [Dynamic] The arguments to create rule sets for.
  ##
  def self.create_rule_sets(args)

    rule_sets = []

    args.each do |arg|
      rule_set = RuleSet.new()
      rule_set.create_rules(arg)
      rule_sets << rule_set
    end

    return rule_sets

  end

  ##
  # Create a RuleSet for each argument.
  #
  # @param args [Dynamic] The arguments to create rule sets for.
  ##
  def self.create_rule_set(arg)

    rule_set = RuleSet.new()
    rule_set.create_rules(arg)

    return rule_set

  end

  def train_from_data(arg)

    # Track data type.
    type = arg.class
    @types << type

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
      else1
        rule = @rules[IntegerRule]
      end
    end

    # Train rule.
    unless rule.nil?
      rule.train(arg)
    end

    return self

  end

  def train_from_rule(rule)

    # Track data type.
    @types << type

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

    # Add value to rule.
    unless rule.nil?
      rule.load(value)
    end

    return self

  end

  def train()

    @rules.each do |klass, rule|
      rule.train()
    end

  end

  def validate_rule(value)
    result = true

    @rules.each do |klass, rule|

      unless rule.validate(value)
        result = false
      end
    end

    return result
  end

end
