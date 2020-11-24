require 'Meta'

class IntegerMeta < Meta

  def initialize()

    @value = nil

  end

  ##
  # @param value [Integer]
  ##
  def load(value)

    @value = value

  end

  def result()
    {
      :type => :int,
      :value => @value
    }
  end

end
