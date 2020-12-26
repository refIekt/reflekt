################################################################################
# Access variables via one object to avoid polluting the caller class scope.
#
# @pattern Singleton
#
# @note Some variables are not accessed via Accessor:
#   - @reflekt_counts on the instance
#   - @@reflekt_skipped_methods on the instance's singleton class
################################################################################

module Reflekt
class Accessor

  attr_accessor :config
  attr_accessor :setup
  attr_accessor :db
  attr_accessor :stack
  attr_accessor :aggregator
  attr_accessor :renderer
  attr_accessor :path
  attr_accessor :output_path
  attr_accessor :error

  def initialize()

    @config = nil
    @setup = nil
    @db = nil
    @stack = nil
    @aggregator = nil
    @renderer = nil
    @path = nil
    @output_path = nil
    @error = false

  end

end
end
