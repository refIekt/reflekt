################################################################################
# A shapshot of real data.
#
# @hierachy
#   1. Execution
#   2. Control
#   3. RuleSet
################################################################################

require 'Reflection'
require 'MetaBuilder'

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

    # Create metadata for each argument.
    @inputs = MetaBuilder.create_many(args)

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

end
