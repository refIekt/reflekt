################################################################################
# RULE POOL
#
# A collection of unique rules that validate an argument.
################################################################################

require 'set'
require 'rules/FloatRule'
require 'rules/IntegerRule'
require 'rules/StringRule'

class RuleSet

  attr_accessor :types
  attr_accessor :rules

  def initialize()

    @types = Set.new
    @rules = {}

  end

  def load(type, value)

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

    rules.each do |klass, rule|
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
