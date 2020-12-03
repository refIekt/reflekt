require 'Meta'

class StringMeta < Meta

  def initialize()

    @type = :string
    @length = nil

  end

  ##
  # @param value [String]
  ##
  def load(value)
    @length = value.length
  end

  def result()
    {
      :type => @type,
      :length => @length
    }
  end

end
