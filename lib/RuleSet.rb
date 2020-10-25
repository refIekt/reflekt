################################################################################
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
      else
        rule = @rules[IntegerRule]
      end
    end

    # Train rule.
    unless rule.nil?
      rule.train(arg)
    end

  end

  def result()

    result = {
      :types => @types,
      :rules => []
    }

    @rules.each do |rule|
      result[:rules] << rule.result()
    end

  end

end
