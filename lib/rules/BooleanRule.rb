require 'set'
require 'Rule'

class BooleanRule < Rule

  def initialize()

    @booleans = Set.new()

  end

  ##
  # @param meta [BooleanMeta]
  ##
  def train(meta)

    value = meta[:value]

    unless value.nil?
      @booleans << value
    end

  end

  ##
  # @param value [Boolean]
  ##
  def test(value)

    @booleans.include? value

  end

  def result()
    {
      :type => :bool,
      :is_true => @booleans.include?,
      :is_false => @booleans.include?
    }
  end

end
