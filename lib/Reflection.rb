class Reflection

  attr_accessor :clone

  def initialize(execution)

    @execution = execution
    @clone = execution.object.clone
    @clone_id = nil

  end

  ##
  # Reflect on a method.
  #
  # @param method - The name of the method.
  # @param *args - The method arguments.
  #
  # @return - A reflection hash.
  ##
  def reflect(method, *args)

    class_name = @clone.class.to_s
    method_name = method.to_s

    # TODO: Create control fork. Get good value. Check against it.

    # Create new arguments that are deviations on inputted type.
    input = []

    args.each do |arg|
      case arg
      when Integer
        input << rand(9999)
      else
        input << arg
      end
    end

    # Action method with new arguments.
    begin
      output = @clone.send(method, *input)

      # Build reflection.
      reflection = {
        REFLEKT_TIME => Time.now.to_i,
        REFLEKT_INPUT => reflekt_normalize_input(input),
        REFLEKT_OUTPUT => reflekt_normalize_output(output)
      }

    # When fail.
    rescue StandardError => message
      reflection[REFLEKT_STATUS] = REFLEKT_MESSAGE
      reflection[REFLEKT_MESSAGE] = message
    # When pass.
    else
      reflection[REFLEKT_STATUS] = REFLEKT_PASS
    end

  end

end
