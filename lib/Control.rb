################################################################################
# A shapshot of real data.
#
# A control's @number property will always be zero.
#
# @hierachy
#   1. Execution
#   2. Control <- YOU ARE HERE
#   3. Meta
################################################################################

require 'Reflection'
require 'MetaBuilder'

class Control < Reflection

  ##
  # Reflect on a method.
  #
  # Creates a shadow execution.
  # @param *args [Dynamic] The method's arguments.
  ##
  def reflect(*args)

    # Get aggregated rule sets.
    input_rule_sets = @aggregator.get_input_rule_sets(@klass, @method)
    output_rule_set = @aggregator.get_output_rule_set(@klass, @method)

    # When arguments exist.
    unless args.size == 0

      # When aggregated rule sets exist.
      unless input_rule_sets.nil?

        # Validate arguments against aggregated rule sets.
        unless @aggregator.test_inputs(args, input_rule_sets)
          @status = :fail
        end

      end

      # Create metadata for each argument.
      # TODO: Create metadata for other inputs such as properties on the instance.
      @inputs = MetaBuilder.create_many(args)

    end

    # Action method with new/old arguments.
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

    # When fail.
    rescue StandardError => message

      @status = :fail
      @message = message

    end

  end

end
