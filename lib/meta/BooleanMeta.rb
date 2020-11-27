require 'Meta'

class BooleanMeta < Meta

  def initialize()
    @value = nil
  end

  ##
  # @param value [Boolean]
  ##
  def load(value)
    @value = value
  end

  def result()
    {
      :type => :bool,
      :value => @value
    }
  end

end
