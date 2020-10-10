require 'Reflection'

class Control < Reflection

  ##
  # Reflect on a method.
  #
  # Creates a shadow execution stack.
  #
  # @param method - The name of the method.
  # @param *args - The method arguments.
  #
  # @return - A reflection hash.
  ##
  def reflect(*args)

    @inputs = *args

    # Action method with new arguments.
    begin
      @output = @clone.send(@method, *@inputs)
    # When fail.
    rescue StandardError => message
      @status = FAIL
      @message = message
    # When pass.
    else
      @status = PASS
    end

  end

end
