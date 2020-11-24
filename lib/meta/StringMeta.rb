require 'Meta'

class StringMeta < Meta

  def initialize()

    @length = nil

  end

  ##
  # @param value [Integer]
  ##
  def load(value)

    @length = value.length

  end

  def result()
    {
      :type => :string,
      :length => @length
    }
  end

end
