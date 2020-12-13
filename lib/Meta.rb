################################################################################
# Metadata for input and output.
#
# @pattern Abstract class
# @see lib/meta for each meta.
#
# @hierachy
#   1. Action
#   2. Reflection
#   3. Meta <- YOU ARE HERE
################################################################################

class Meta

  ##
  # Each meta defines its type.
  ##
  def initialize()
    @type = nil
  end

  ##
  # Each meta loads values.
  #
  # @param value [Dynamic]
  ##
  def load(value)
  end

  ##
  # Each meta serializes metadata.
  #
  # @return [Hash]
  ##
  def serialize()
    {}
  end

  ##############################################################################
  # CLASS
  ##############################################################################

  ##
  # Deserialize metadata.
  #
  # @todo Deserialize should create a Meta object.
  # @todo Require each Meta type to handle its own deserialization.
  #
  # @param meta [Hash] The metadata to deserialize.
  # @param meta [Hash]
  ##
  def self.deserialize(meta)

    # Convert nil meta into NullMeta.
    # Meta is nil when there are no @inputs or @output on the method.
    if meta.nil?
      return NullMeta.new().serialize()
    end

    # Symbolize keys.
    # TODO: Remove once "Fix Rowdb.get(path)" bug fixed.
    meta = meta.transform_keys(&:to_sym)

    # Symbolize type value.
    meta[:type] = meta[:type].to_sym

    return meta

  end

end
