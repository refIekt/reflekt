class Reflection

  attr_accessor :clone

  ##
  # Create a Reflection.
  #
  # @param Execution execution - The Execution that created this Reflection.
  # @param Integer number - Multiple Reflections can be created per Execution.
  # @param Ruler ruler - The RuleSets for this class/method.
  ##
  def initialize(execution, number, ruler)

    @execution = execution
    @unique_id = execution.unique_id + number
    @number = number

    # Dependency.
    @ruler = ruler

    # Caller.
    @klass = execution.klass
    @method = execution.method

    # Arguments.
    @inputs = []
    @output = nil

    # Clone the execution's calling object.
    @clone = execution.caller_object.clone
    @clone_id = nil

    # Result.
    @status = :pass
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
          @status = :fail
        end
      end

      # Run reflection.
      @output = @clone.send(@method, *@inputs)

      # Validate output with controls.
      unless output_rule_set.nil?
        unless @ruler.validate_output(@output, output_rule_set)
          @status = :fail
        end
      end

    # When fail.
    rescue StandardError => message
      @status = :fail
      @message = message
    end

  end

  def result()

    # The ID of the first execution in the ShadowStack.
    base_id = nil
    unless @execution.base == nil
      base_id = @execution.base.unique_id
    end

    # Build reflection.
    reflection = {
      :base_id => base_id,
      :execution_id => @execution.unique_id,
      :reflection_id => @unique_id,
      :reflection_number => @number,
      :time => @time,
      :class => @klass,
      :method => @method,
      :status => @status,
      :input => normalize_input(@inputs),
      :output => normalize_output(@output),
      :message => @message
    }

    return reflection
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
        :type => arg.class.to_s,
        :value => normalize_value(arg)
      }
      if (arg.class == Array)
        input[:count] = arg.count
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
      :type => input.class.to_s,
      :value => normalize_value(input)
    }

    if (input.class == Array || input.class == Hash)
      output[:count] = input.count
    elsif (input.class == TrueClass || input.class == FalseClass)
      output[:type] = :Boolean
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
