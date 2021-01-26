module Reflekt
  class Config

    attr_accessor :enabled
    attr_accessor :reflect_amount
    attr_accessor :reflect_limit
    attr_accessor :meta_map
    attr_accessor :project_path
    attr_accessor :output_directory

    def initialize()

      # Reflekt is enabled by default and should be disabled on production.
      @enabled = true

      # Reflekt is untracked in git by default.
      @git_ignore = true

      # The amount of reflections to create per method call.
      # A control reflection is created in addition to this.
      @reflect_amount = 5

      # The maximum amount of reflections that can be created per instance per method.
      # A method called thousands of times doesn't need that many reflections.
      @reflect_limit = 10

      # The rules that apply to meta types.
      @meta_map = {
        :array  => [ArrayRule],
        :bool   => [BooleanRule],
        :int    => [IntegerRule],
        :float  => [FloatRule],
        :null   => [NullRule],
        :object => [ObjectRule],
        :string => [StringRule]
      }

      # An absolute path to the project root directory.
      # Defaults to current execution path.
      @project_path = Dir.pwd

      # Name of output directory.
      @output_directory = "reflections"

    end

  end
end
