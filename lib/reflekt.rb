require 'set'
require 'erb'
require 'rowdb'
require 'Execution'
require 'Reflection'
require 'ShadowStack'

################################################################################
# REFLEKT
#
# Usage. Prepend to the class like so:
#
#   class ExampleClass
#     prepend Reflekt
################################################################################

module Reflekt

  # Reflection keys.
  REFLEKT_TIME    = "t"
  REFLEKT_INPUT   = "i"
  REFLEKT_OUTPUT  = "o"
  REFLEKT_TYPE    = "T"
  REFLEKT_COUNT   = "C"
  REFLEKT_VALUE   = "V"
  REFLEKT_STATUS  = "s"
  REFLEKT_MESSAGE = "m"
  # Reflection values.
  REFLEKT_PASS    = "p"
  REFLEKT_FAIL    = "f"

  @@reflection_count = 1

  def initialize(*args)

    @reflekt_constructed = false
    @reflekt_clones = []

    # Limit the amount of reflections that can be created per instance.
    # A method called thousands of times doesn't need that many reflections.
    @reflection_limit = 5
    @reflected_count = 0

    # Override methods.
    self.class.instance_methods(false).each do |method|
      self.define_singleton_method(method) do |*args|

        # Get current or next execution.
        execution = @@reflekt_stack.peek()
        if execution.nil? || execution.executed?
          execution = @@reflekt_stack.push(self, @@reflection_count)
        end

        # Reflect.
        if execution.reflect? && @reflekt_constructed && !self.class.reflekt_skipped?(method)
          if @reflected_count < @reflection_limit

            # Reflect on method.
            @@reflection_count.times do
              reflection = Reflection.new(execution)
              reflection_hash = reflection.reflect(method, *args)
              @@reflekt_db.get("#{class_name}.#{method_name}").push(reflection_hash)
            end

            # Save results.
            @@reflekt_db.write()

            reflekt_render()

            #@@reflekt_stack.display

            @reflected_count = @reflected_count + 1
          end

        end

        # Execute.
        unless execution.executed?
          execution.executed = true
          super *args
        end

      end

    end

    # Construct object.
    super

    # Construct reflekt.
    reflekt_construct()

  end

  def reflekt_construct()

    @@reflection_count.times do |clone|
      @reflekt_clones << self.clone
    end

    @reflekt_constructed = true

  end

  ##
  # Normalize inputs.
  #
  # @param args - The actual inputs.
  # @return - A generic inputs representation.
  ##
  def reflekt_normalize_input(args)
    inputs = []
    args.each do |arg|
      input = {
        REFLEKT_TYPE => arg.class.to_s,
        REFLEKT_VALUE => reflekt_normalize_value(arg)
      }
      if (arg.class == Array)
        input[REFLEKT_COUNT] = arg.count
      end
      inputs << input
    end
    inputs
  end

  ##
  # Normalize output.
  #
  # @param output - The actual output.
  # @return - A generic output representation.
  ##
  def reflekt_normalize_output(output)

    o = {
      REFLEKT_TYPE => output.class.to_s,
      REFLEKT_VALUE => reflekt_normalize_value(output)
    }

    if (output.class == Array || output.class == Hash)
      o[REFLEKT_COUNT] = output.count
    elsif (output.class == TrueClass || output.class == FalseClass)
      o[REFLEKT_TYPE] = :Boolean
    end

    return o

  end

  def reflekt_normalize_value(value)

    unless value.nil?
      value = value.to_s.gsub(/\r?\n/, " ").to_s
      if value.length >= 30
        value = value[0, value.rindex(/\s/,30)].rstrip() + '...'
      end
    end

    return value

  end

  def reflekt_render()

    # Render results.
    @@reflekt_json = File.read("#{@@reflekt_output_path}/db.json")
    template = File.read("#{@@reflekt_path}/web/template.html.erb")
    rendered = ERB.new(template).result(binding)
    File.open("#{@@reflekt_output_path}/index.html", 'w+') do |f|
      f.write rendered
    end

    # Add JS.
    javascript = File.read("#{@@reflekt_path}/web/script.js")
    File.open("#{@@reflekt_output_path}/script.js", 'w+') do |f|
      f.write javascript
    end

    # Add CSS.
    stylesheet = File.read("#{@@reflekt_path}/web/style.css")
    File.open("#{@@reflekt_output_path}/style.css", 'w+') do |f|
      f.write stylesheet
    end

  end

  private

  def self.prepended(base)
    # Prepend class methods to the instance's singleton class.
    base.singleton_class.prepend(SingletonClassMethods)

    @@reflekt_setup ||= reflekt_setup_class
  end

  # Setup class.
  def self.reflekt_setup_class()

    # Receive configuration.
    $ENV ||= {}
    $ENV[:reflekt] ||= $ENV[:reflekt] = {}

    # Set configuration.
    @@reflekt_path = File.dirname(File.realpath(__FILE__))

    # Create reflection tree.
    @@reflekt_stack = ShadowStack.new()

    # Build reflections directory.
    if $ENV[:reflekt][:output_path]
      @@reflekt_output_path = File.join($ENV[:reflekt][:output_path], 'reflections')
    # Build reflections directory in current execution path.
    else
      @@reflekt_output_path = File.join(Dir.pwd, 'reflections')
    end
    # Create reflections directory.
    unless Dir.exist? @@reflekt_output_path
      Dir.mkdir(@@reflekt_output_path)
    end

    # Create database.
    @@reflekt_db = Rowdb.new(@@reflekt_output_path + '/db.json')
    @@reflekt_db.defaults({ :reflekt => { :api_version => 1 }}).write()

    return true
  end

  module SingletonClassMethods

    @@reflekt_skipped_methods = Set.new

    ##
    # Skip a method.
    #
    # @param method - A symbol representing the method name.
    ##
    def reflekt_skip(method)
      @@reflekt_skipped_methods.add(method)
    end

    def reflekt_skipped?(method)
      return true if @@reflekt_skipped_methods.include?(method)
      false
    end

    def reflekt_limit(amount)
      @reflection_limit = amount
    end

  end

end
