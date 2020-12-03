require 'Meta'

class BooleanMeta < Meta

  def initialize()

    @type = :bool
    @value = nil

  end

  ##
  # @param value [Boolean]
  ##
  def load(value)
    @value = value.to_s
  end

  def result()
    {
      :type => @type,
      :value => @value
    }
  end

end
