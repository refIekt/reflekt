################################################################################
# A collection of rules that validate an argument.
################################################################################

require 'set'
require 'rules/IntegerRule'
require 'rules/StringRule'

class RuleSet

  attr_accessor :type
  attr_accessor :rules

  def initialize()

    @type = nil
    @rules = {}

  end

  ##
  # Get the results of the rules.
  #
  # @return [Array] The rules.
  ##
  def result()

    rules = {}

    @rules.each do |key, rule|
      rules[rule.class] = rule.result()
    end

    return rules

  end

end
