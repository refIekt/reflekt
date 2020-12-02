################################################################################
# A shapshot of real data.
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
  # Get the results of the control reflection.
  #
  # @return [Hash] Reflection metadata.
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
      :time => @time,
      :class => @klass,
      :method => @method,
      :status => @status,
      :message => @message,
      :inputs => nil,
      :output => @output,
    }
    unless @inputs.nil?
      control[:inputs] = []
      @inputs.each do |meta|
        control[:inputs] << meta.result()
      end
    end

    return control

  end

end
