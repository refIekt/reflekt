class Reflection

  # Reflection keys.
  REFLEKT_TIME    = "t"
  REFLEKT_INPUT   = "i"
  REFLEKT_OUTPUT  = "o"
  REFLEKT_TYPE    = "T"
  REFLEKT_COUNT   = "C"
  REFLEKT_VALUE   = "V"
  REFLEKT_STATUS  = "s"
  REFLEKT_MESSAGE = "m"
  # Reflection values.
  REFLEKT_PASS    = "p"
  REFLEKT_FAIL    = "f"

  attr_accessor :clone

  def initialize(execution)

    @execution = execution

    # Clone the execution's object.
    @clone = execution.object.clone
    @clone_id = nil

    @output = nil

  end

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
  def reflect(method, *args)

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
      @output = @clone.send(method, *input)

      # Build reflection.
      reflection = {
        REFLEKT_TIME => Time.now.to_i,
        REFLEKT_INPUT => normalize_input(input),
        REFLEKT_OUTPUT => normalize_output(output)
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

  ##
  # Normalize inputs.
  #
  # @param args - The actual inputs.
  # @return - A generic inputs representation.
  ##
  def normalize_input(args)
    inputs = []
    args.each do |arg|
      input = {
        REFLEKT_TYPE => arg.class.to_s,
        REFLEKT_VALUE => normalize_value(arg)
      }
      if (arg.class == Array)
        input[REFLEKT_COUNT] = arg.count
      end
      inputs << input
    end
    inputs
  end

  ##
  # Normalize output.
  #
  # @param input - The actual output.
  # @return - A generic output representation.
  ##
  def normalize_output(input)

    output = {
      REFLEKT_TYPE => input.class.to_s,
      REFLEKT_VALUE => normalize_value(output)
    }

    if (input.class == Array || input.class == Hash)
      output[REFLEKT_COUNT] = input.count
    elsif (input.class == TrueClass || input.class == FalseClass)
      output[REFLEKT_TYPE] = :Boolean
    end

    return output

  end

  def normalize_value(value)

    unless value.nil?
      value = value.to_s.gsub(/\r?\n/, " ").to_s
      if value.length >= 30
        value = value[0, value.rindex(/\s/,30)].rstrip() + '...'
      end
    end

    return value

  end

end
