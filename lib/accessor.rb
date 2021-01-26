################################################################################
# Access variables via one object to avoid polluting the caller's scope.
#
# @pattern Singleton
#
# @note Variables not accessed via Accessor:
#   - @reflekt_counts on the instance
#   - @@reflekt_skipped_methods on the instance's singleton class
################################################################################

module Reflekt
  class Accessor

    attr_accessor :config
    attr_accessor :db
    attr_accessor :stack
    attr_accessor :aggregator
    attr_accessor :renderer
    attr_accessor :package_path
    attr_accessor :project_path
    attr_accessor :output_path
    attr_accessor :error

    def initialize()
      @config = nil
      @db = nil
      @stack = nil
      @aggregator = nil
      @renderer = nil
      @package_path = nil
      @project_path = nil
      @output_path = nil
      @error = false
    end

  end
end
