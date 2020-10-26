################################################################################
# A collection of rules that validate an argument.
################################################################################

require 'set'
require 'rules/FloatRule'
require 'rules/IntegerRule'
require 'rules/StringRule'

class RuleSet

  attr_accessor :type
  attr_accessor :rules

  def initialize()

    @type = nil
    @rules = {}

  end

end
