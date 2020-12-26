################################################################################
# A shapshot of real data.
#
# @note
#   A control's @number will always be 0.
#
# @nomenclature
#   args, inputs/output and meta represent different stages of a value.
#
# @hierachy
#   1. Action
#   2. Control <- YOU ARE HERE
#   3. Meta
#
# @status
#   - :pass [Symbol] The reflection passes the rules.
#   - :fail [Symbol] The reflection fails the rules or produces a system error.
#   - :error [Symbol] The control reflection produces a system error.
################################################################################

require_relative 'reflection'
require_relative 'meta_builder'

module Reflekt
class Control < Reflection

  ##
  # Reflect on a method.
  #
  # Create a shadow action.
  # @param *args [Dynamic] The method's arguments.
  ##
  def reflect(*args)

    # Get trained rule sets.
    input_rule_sets = @aggregator.get_input_rule_sets(@klass, @method)
    output_rule_set = @aggregator.get_output_rule_set(@klass, @method)

    # Fail when no trained rule sets.
    if input_rule_sets.nil?
      @status = :fail
    end

    # When arguments exist.
    unless args.size == 0

      # Validate arguments against trained rule sets.
      unless input_rule_sets.nil?
        unless @aggregator.test_inputs(args, input_rule_sets)
          @status = :fail
        end
      end

      # Create metadata for each argument.
      # TODO: Create metadata for other inputs such as instance variables.
      @inputs = MetaBuilder.create_many(args)

    end

    # Action method with real arguments.
    begin

      # Run reflection.
      output = @clone.send(@method, *args)
      @output = MetaBuilder.create(output)

      # Validate output with aggregated control rule sets.
      unless output_rule_set.nil?
        unless @aggregator.test_output(output, output_rule_set)
          @status = :fail
        end
      end

    # When a system error occurs.
    rescue StandardError => message

      @status = :error
      @message = message

    end

  end

end
end
