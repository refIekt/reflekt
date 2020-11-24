################################################################################
# Create Meta.
#
# @pattern Builder.
# @see lib/meta for each meta.
################################################################################

require 'Meta'
require_relative './meta/IntegerMeta'
require_relative './meta/StringMeta'

class MetaBuilder

  ##
  # Create meta.
  #
  # @param value
  ##
  def self.create(value)

    meta = nil

    # Creates values for matching data type.
    case value.class.to_s
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
