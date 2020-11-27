require 'Meta'

class ArrayMeta < Meta

  def initialize()

    @min = nil
    @max = nil
    @length = nil

  end

  ##
  # @param value [Array]
  ##
  def load(value)

    @min = value.min()
    @max = value.max()
    @length = value.length()

  end

  def result()
    {
      :type => :array,
      :max => @max,
      :min => @min,
      :length => @length
    }
  end

end
