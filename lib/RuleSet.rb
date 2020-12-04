################################################################################
# A collection of rules that validate metadata.
#
# @patterns
#   - Dependency Injection
#   - Builder
#
# @hierachy
#   1. Aggregator
#   2. RuleSet <- YOU ARE HERE
#   3. Rule
################################################################################

require 'set'
require 'MetaBuilder'

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
  # @param meta [Meta] The metadata to train on.
  ##
  def train(meta)

    p '--- meta ---'
    p meta

    unless meta.nil? || meta[:type].nil?

      meta_type = meta[:type]
      @meta_types << meta_type

      p meta_type
      p @meta_types

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

      p '-- rule set train --'
      p @rules

    end

  end

  def test(value)
    result = true

    # Only test data type on rule of matching meta type.
    meta_type = MetaBuilder.data_type_to_meta_type(value)

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
