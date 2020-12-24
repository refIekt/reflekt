require_relative '../meta'

class IntegerMeta < Meta

  def initialize()

    @type = :int
    @value = nil

  end

  ##
  # @param value [Integer]
  ##
  def load(value)
    @value = value
  end

  def serialize()
    {
      :type => @type,
      :value => @value
    }
  end

end
