require 'Meta'

class FloatMeta < Meta

  def initialize()

    @type = :float
    @value = nil

  end

  ##
  # @param value [Float]
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
