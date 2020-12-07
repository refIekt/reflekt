require 'Rule'

class NullRule < Rule

  def initialize()
    @type = :null
  end

  ##
  # @param meta [NullMeta]
  ##
  def train(meta)
    # No need to train. NullMeta is always null.
  end

  ##
  # @param value [NilClass]
  ##
  def test(value)

    return false unless value.nil?
    return true

  end

  def result()
    {
      :type => @type
    }
  end

  def random()
    nil
  end

end
