################################################################################
# A shapshot of real data.
#
# @hierachy
#   1. Execution
#   2. Control
#   3. RuleSet
################################################################################

require 'Reflection'

class Control < Reflection

  ##
  # Reflect on a method.
  #
  # Creates a shadow execution stack.
  #
  # @param method [Symbol] The name of the method.
  # @param *args [Args] The method arguments.
  # @return [Hash] A reflection hash.
  ##
  def reflect(*args)

    # Action method with new arguments.
    begin
      output = @clone.send(@method, *args)
    # When fail.
    rescue StandardError => message
      @status = :fail
      @message = message
    # When pass.
    else
      @status = :pass
    end

  end

  ##
  # Provide the results of the control.
  #
  # @return [Hash] Control metadata.
  ##
  def result()

    # The ID of the first execution in the ShadowStack.
    base_id = nil
    unless @execution.base == nil
      base_id = @execution.base.unique_id
    end

    # Build control.
    control = {
      :base_id => base_id,
      :exe_id => @execution.unique_id,
      :ref_id => @unique_id,
      :ref_num => @number,
      :time => @time,
      :class => @klass,
      :method => @method,
      :status => @status,
      :inputs => @inputs,
      :output => @output,
      :message => @message
    }

    return control

  end

end
