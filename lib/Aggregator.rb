################################################################################
# Aggregate reflection metadata into rule sets.
# Validate reflection arguments against aggregates.
#
# @pattern Singleton
#
# @hierachy
#   1. Aggregator <- YOU ARE HERE
#   2. RuleSet
#   3. Rule
################################################################################

require 'RuleSet'

class Aggregator

  ##
  # @param meta_map [Hash] The rules that apply to each meta type.
  ##
  def initialize(meta_map)

    @meta_map = meta_map
    # Key rule sets by class and method.
    @rule_sets = {}

  end

  ##
  # Get aggregated RuleSets for all inputs.
  #
  # @param klass [Symbol]
  # @param method [Symbol]
  # @return [Array]
  ##
  def get_input_rule_sets(klass, method)
    return @rule_sets.dig(klass, method, :inputs)
  end

  ##
  # Get an aggregated RuleSet for an input.
  #
  # @param klass [Symbol]
  # @param method [Symbol]
  # @return [RuleSet]
  ##
  def get_input_rule_set(klass, method, arg_num)
    @rule_sets.dig(klass, method, :inputs, arg_num)
  end

  ##
  # Get an aggregated RuleSet for an output.
  #
  # @param klass [Symbol]
  # @param method [Symbol]
  # @return [RuleSet]
  ##
  def get_output_rule_set(klass, method)
    @rule_sets.dig(klass, method, :output)
  end

  ##
  # Set an aggregated RuleSet for an input.
  #
  # @param klass [Symbol]
  # @param method [Symbol]
  ##
  def set_input_rule_set(klass, method, arg_num, rule_set)
    # Set defaults.
    @rule_sets[klass] = {} unless @rule_sets.key? klass
    @rule_sets[klass][method] = {} unless @rule_sets[klass].key? method
    @rule_sets[klass][method][:inputs] = [] unless @rule_sets[klass][method].key? :inputs
    # Set value.
    @rule_sets[klass][method][:inputs][arg_num] = rule_set
  end

  ##
  # Set an aggregated RuleSet for an output.
  #
  # @param klass [Symbol]
  # @param method [Symbol]
  # @param rule_set [RuleSet]
  ##
  def set_output_rule_set(klass, method, rule_set)
    # Set defaults.
    @rule_sets[klass] = {} unless @rule_sets.key? klass
    @rule_sets[klass][method] = {} unless @rule_sets[klass].key? method
    # Set value.
    @rule_sets[klass][method][:output] = rule_set
  end

  ##
  # Create aggregated rule sets from reflection metadata.
  #
  # @param reflections [Array] Controls with metadata.
  ##
  def train(reflections)

    # On first use there are no previous reflections.
    return if reflections.nil?

    reflections.each do |reflection|

      klass = reflection[:class]
      method = reflection[:method]

      ##
      # INPUT
      ##

      unless reflection[:inputs].nil?
        reflection[:inputs].each_with_index do |meta, arg_num|

          # Get rule set.
          rule_set = get_input_rule_set(klass, method, arg_num)
          if rule_set.nil?
            rule_set = RuleSet.new(@meta_map)
            set_input_rule_set(klass, method, arg_num, rule_set)
          end

          # Train on metadata.
          rule_set.train(meta)

        end
      end

      ##
      # OUTPUT
      ##

      # Get rule set.
      output_rule_set = get_output_rule_set(klass, method)
      if output_rule_set.nil?
        output_rule_set = RuleSet.new(@meta_map)
        set_output_rule_set(klass, method, output_rule_set)
      end

      # Train on metadata.
      output_rule_set.train(reflection[:output])

    end

  end

  ##
  # Validate inputs.
  #
  # @param inputs [Array] The method's arguments.
  # @param input_rule_sets [Array] The RuleSets to validate each input with.
  ##
  def validate_inputs(inputs, input_rule_sets)

    # Default to a PASS result.
    result = true

    # Validate each argument against each RuleSet for that argument.
    inputs.each_with_index do |input, arg_num|

      unless input_rule_sets[arg_num].nil?

        rule_set = input_rule_sets[arg_num]

        unless rule_set.validate_rule(input)
          result = false
        end

      end
    end

    return result

  end

  ##
  # Validate output.
  #
  # @param output [Dynamic] The method's return value.
  # @param output_rule_set [RuleSet] The RuleSet to validate the output with.
  ##
  def validate_output(output, output_rule_set)

    # Default to a PASS result.
    result = true

    unless output_rule_set.nil?

      # Validate output RuleSet for that argument.
      unless output_rule_set.validate_rule(output)
        result = false
      end

    end

    return result

  end

end
