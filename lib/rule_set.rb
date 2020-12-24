################################################################################
# A collection of rules that validate metadata.
#
# @patterns
#   - Dependency Injection
#   - Builder
#
# @hierachy
#   1. RuleSetAggregator
#   2. RuleSet <- YOU ARE HERE
#   3. Rule
################################################################################

require 'set'
require_relative 'meta_builder'
require_relative 'meta/NullMeta.rb'

class RuleSet

  attr_accessor :rules

  ##
  # @param meta_map [Hash] The rules to apply to each data type.
  ##
  def initialize(meta_map)

    # The rules that apply to meta types.
    @meta_map = meta_map

    # The types of meta this rule set applies to.
    # Rules are only validated on their supported meta type.
    @meta_types = Set.new()

    @rules = {}

  end

  ##
  # Train rule set on metadata.
  #
  # @param meta [Hash] The metadata to train on.
  ##
  def train(meta)

    # Track supported meta types.
    meta_type = meta[:type]
    @meta_types << meta_type

    # Get rule types for this meta type.
    if @meta_map.key? meta_type
      @meta_map[meta_type].each do |rule_type|

        # Ensure rule exists.
        if @rules[rule_type].nil?
          @rules[rule_type] = rule_type.new()
        end

        # Train rule.
        @rules[rule_type].train(meta)

      end
    end

  end

  ##
  # @param value [Dynamic]
  ##
  def test(value)

    result = true
    meta_type = MetaBuilder.data_type_to_meta_type(value)

    # Fail if value's meta type not testable by rule set.
    unless @meta_types.include? meta_type
      return false
    end

    @rules.each do |klass, rule|
      if (rule.type == meta_type)
        unless rule.test(value)
           result = false
        end
      end
    end

    return result

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
