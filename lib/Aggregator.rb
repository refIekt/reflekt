################################################################################
# Aggregate control metadata into rule sets.
# Validate reflections against aggregated controls.
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
  # Create aggregated rule sets from control metadata.
  #
  # @param controls [Array] Controls with metadata.
  # @TODO Revert string keys to symbols once "Fix Rowdb.get(path)" bug fixed.
  ##
  def train(controls)

    # On first use there are no previous controls.
    return if controls.nil?

    controls.each do |control|

      klass = control["class"].to_sym
      method = control["method"].to_sym

      ##
      # INPUT
      ##

      unless control["inputs"].nil?
        control["inputs"].each_with_index do |meta, arg_num|

          # TODO: Remove once "Fix Rowdb.get(path)" bug fixed.
          meta = meta.transform_keys(&:to_sym)
          # Deserialize meta type to symbol.
          meta[:type] = meta[:type].to_sym

          # Get rule set.
          rule_set = get_input_rule_set(klass, method, arg_num)
          if rule_set.nil?
            rule_set = RuleSet.new(@meta_map)
            set_input_rule_set(klass, method, arg_num, rule_set)
          end

          # Train on metadata.
          rule_set.train(meta)

          p '-- rule set after train --'
          p rule_set

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
      output_rule_set.train(control["output"])

    end

    p '--- trained rule_sets ---'
    p @rule_set

  end

  ##
  # Validate inputs.
  #
  # @param inputs [Array] The method's arguments.
  # @param input_rule_sets [Array] The RuleSets to validate each input with.
  ##
  def validate_inputs(inputs, input_rule_sets)

    # Default result to PASS.
    result = true

    # Validate each argument against each rule set for that argument.
    inputs.each_with_index do |input, arg_num|

      unless input_rule_sets[arg_num].nil?

        rule_set = input_rule_sets[arg_num]

        p '--- rule_set rules ---'
        p rule_set.rules

        unless rule_set.test(input)
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

  ##
  # Get aggregated RuleSets for all inputs.
  #
  # @param klass [Symbol]
  # @param method [Symbol]
  # @return [Array]
  ##
  def get_input_rule_sets(klass, method)
    @rule_sets.dig(klass, method, :inputs)
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

  private

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

end
