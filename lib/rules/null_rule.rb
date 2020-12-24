require_relative '../rule'

class NullRule < Rule

  def initialize()
    @type = :null
  end

  ##
  # @param meta [NullMeta]
  ##
  def train(meta)
    # No need to train as NullMeta is always nil.
  end

  ##
  # @param value [NilClass]
  ##
  def test(value)
    value.nil?
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
