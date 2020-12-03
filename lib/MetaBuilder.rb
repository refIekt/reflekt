################################################################################
# Create metadata.
#
# @pattern Builder
# @see lib/meta for each meta.
################################################################################

require 'Meta'
# Require all meta.
Dir[File.join(__dir__, 'meta', '*.rb')].each { |file| require file }

class MetaBuilder

  ##
  # Create meta.
  #
  # @param value
  ##
  def self.create(value)

    meta = nil
    data_type = value.class.to_s

    # Create meta type for matching data type.
    case data_type
    when "Array"
      meta = ArrayMeta.new()
    when "TrueClass", "FalseClass"
      meta = BooleanMeta.new()
    when "Float"
      meta = FloatMeta.new()
    when "Integer"
      meta = IntegerMeta.new()
    when "String"
      meta = StringMeta.new()
    end

    unless meta.nil?
      meta.load(value)
    end

    return meta

  end

  ##
  # Create meta for multiple values.
  #
  # @param values
  ##
  def self.create_many(values)

    meta = []

    values.each do |value|
      meta << self.create(value)
    end

    return meta

  end

end
