################################################################################
# A snapshot of random data.
#
# @note
#   A reflection's random values are generated from aggregated control rule sets.
#
# @nomenclature
#   args, inputs/output and meta represent different stages of a value.
#
# @hierachy
#   1. Action
#   2. Experiment <- YOU ARE HERE
#   3. Meta
#
# @status
#   - :pass [Symbol] The reflection passes the rules.
#   - :fail [Symbol] The reflection fails the rules or produces a system error.
#   - :error [Symbol] The control reflection produces a system error.
################################################################################

require 'reflection'
require 'meta_builder'

class Experiment < Reflection

  ##
  # Reflect on a method.
  #
  # Create a shadow action.
  # @param *args [Dynamic] The method's arguments.
  ##
  def reflect(*args)

    # Get aggregated rule sets.
    input_rule_sets = @aggregator.get_input_rule_sets(@klass, @method)
    output_rule_set = @aggregator.get_output_rule_set(@klass, @method)

    # Fail when no trained rule sets.
    if input_rule_sets.nil?
      @status = :fail
    end

    # When arguments exist.
    unless args.size == 0

      # Create random arguments from aggregated rule sets.
      unless input_rule_sets.nil?
        args = randomize(args, input_rule_sets)
      end

      # Create metadata for each argument.
      # TODO: Create metadata for other inputs such as instance variables.
      @inputs = MetaBuilder.create_many(args)

    end

    # Action method with random arguments.
    begin

      # Run reflection.
      output = @clone.send(@method, *args)
      @output = MetaBuilder.create(output)

      # Validate output against aggregated control rule sets.
      unless output_rule_set.nil?
        unless @aggregator.test_output(output, output_rule_set)
          @status = :fail
        end
      end

    # When a system error occurs.
    rescue StandardError => message

      @status = :fail
      @message = message

    end

  end

end
