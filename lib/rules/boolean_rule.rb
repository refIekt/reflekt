require 'set'
require_relative '../rule'

module Reflekt
  class BooleanRule < Rule

    def initialize()

      @type = :bool
      @booleans = Set.new()

    end

    ##
    # @param meta [BooleanMeta]
    ##
    def train(meta)

      value = meta[:value]

      unless value.nil?
        @booleans << value
      end

    end

    ##
    # @param value [Boolean]
    ##
    def test(value)

      # Booleans are stored as strings.
      @booleans.include? value.to_s

    end

    def result()
      {
        :type => @type,
        :booleans => @booleans
      }
    end

    def random()
      @booleans.to_a.sample
    end

  end
end
