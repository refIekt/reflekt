require_relative '../rule'

module Reflekt
  class ObjectRule < Rule

    def initialize()
      @type = :object
      @class_type = nil
      # TODO: Populate with meta for each arg.
      @class_args = []
    end

    ##
    # @param meta [ObjectMeta]
    ##
    def train(meta)
      if @class_type.nil?
        @class_type = meta[:class_type]
      end
    end

    ##
    # @param value [NilClass]
    ##
    def test(value)
      value.class.to_s == @class_type
    end

    def result()
      {
        :type => @type,
        :class_type => @class_type
      }
    end

    def random()
      # TODO: Instantiate class with appropriate @class_args metadata.
      eval("#{@class_type}").new()
    end

  end
end
