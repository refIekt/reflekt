################################################################################
# Creates values.
#
# Hierachy:
# 1. ValueSet
# 2. Value
################################################################################

require 'ValueSet'

class ValueController

  def initialize()

    @value_sets = []

  end

  ##
  # Create a value for each argument.
  #
  # @param args [Dynamic] The arguments to create values for.
  ##
  def create_values(args)

    args.each do |arg|
      value = Value.new()
      value.load(arg)
      @values << value.result()
    end

    return @values

  end

  def create_value(arg)

    # Track data type.
    @type = arg.class.to_s

    # Creates values for matching data type.
    case type
    when "Integer"
      value = IntegerValue.new()
      value.train(arg)
      @values[IntegerValue] = value
    when "String"
      value = StringValue.new()
      value.train(arg)
      @values[StringValue] = value
    end

  end

  def result()

    result = {
      :values => []
    }

    @values.each do |key, value|
      result[:values] << value.result()
    end

    return result

  end

end
