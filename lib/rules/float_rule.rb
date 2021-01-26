require_relative '../rule'

module Reflekt
  class FloatRule < Rule

    def initialize()
      @type = :float
      @min = nil
      @max = nil
    end

    ##
    # @param meta [FloatMeta]
    ##
    def train(meta)
      value = meta[:value]

      if @min.nil?
        @min = value
      else
        @min = value if value < @min
      end

      if @max.nil?
        @max = value
      else
        @max = value if value > @max
      end
    end

    ##
    # @param value [Float]
    ##
    def test(value)
      # Numbers only; if the value is a string then there will be no min/max.
      unless @min.nil? || @max.nil?
        return false if value < @min
        return false if value > @max
      end
    end

    def result()
      {
        :type => @type,
        :min => @min,
        :max => @max
      }
    end

    def random()
      rand(@min..@max)
    end

  end
end
