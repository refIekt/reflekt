class Reflection

  # Keys.
  TIME    = "t"
  CLASS   = "k"
  METHOD  = "f"
  INPUT   = "i"
  OUTPUT  = "o"
  STATUS  = "s"
  MESSAGE = "m"
  TYPE    = "T"
  COUNT   = "C"
  VALUE   = "V"
  # Values.
  PASS    = "p"
  FAIL    = "f"

  attr_accessor :clone

  ##
  # Create a Reflection.
  #
  # @param Execution execution - The Execution that created this Reflection.
  # @param Symbol klass - The class of the method being called.
  # @param Symbol method - The method that is being called.
  # @param Ruler ruler - The RuleSets for this class/method.
  ##
  def initialize(execution, ruler)

    @execution = execution
    @klass = execution.klass
    @method = execution.method
    @ruler = ruler

    # Arguments.
    @inputs = []
    @output = nil

    # Clone the execution's object.
    @clone = execution.object.clone
    @clone_id = nil

    # Result.
    @status = PASS
    @time = Time.now.to_i

  end

  ##
  # Reflect on a method.
  #
  # Creates a shadow execution stack.
  #
  # @param *args - The method's arguments.
  #
  # @return - A reflection hash.
  ##
  def reflect(*args)

    # Get RuleSets.
    input_rule_sets = @ruler.get_input_rule_sets(@klass, @method)
    output_rule_set = @ruler.get_output_rule_set(@klass, @method)

    # Create deviated arguments.
    args.each do |arg|
      case arg
      when Integer
        @inputs << rand(999)
      else
        @inputs << arg
      end
    end

    # Action method with new arguments.
    begin

      # Validate input with controls.
      unless input_rule_sets.nil?
        unless @ruler.validate_inputs(@inputs, input_rule_sets)
          @status = FAIL
        end
      end

      # Run reflection.
      @output = @clone.send(@method, *@inputs)

      # Validate output with controls.
      unless output_rule_set.nil?
        unless @ruler.validate_output(@output, output_rule_set)
          @status = FAIL
        end
      end

    # When fail.
    rescue StandardError => message
      @status = FAIL
      @message = message
    end

  end

  def result()
    # Build reflection.
    reflection = {
      TIME => @time,
      CLASS => @klass,
      METHOD => @method,
      STATUS => @status,
      INPUT => normalize_input(@inputs),
      OUTPUT => normalize_output(@output),
      MESSAGE => @message
    }
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
        TYPE => arg.class.to_s,
        VALUE => normalize_value(arg)
      }
      if (arg.class == Array)
        input[COUNT] = arg.count
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
      TYPE => input.class.to_s,
      VALUE => normalize_value(input)
    }

    if (input.class == Array || input.class == Hash)
      output[COUNT] = input.count
    elsif (input.class == TrueClass || input.class == FalseClass)
      output[TYPE] = :Boolean
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
