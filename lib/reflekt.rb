require 'set'

# Production.
require 'rowdb'

# Development.
#require_relative '../../rowdb/lib/rowdb.rb'
#require_relative '../../rowdb/lib/adapters/Adapter.rb'
#require_relative '../../rowdb/lib/adapters/FileSystem.rb'

################################################################################
# REFLEKT
#
# Usage. Prepend to the class like so:
#
#   class ExampleClass
#     prepend Reflekt
################################################################################

module Reflekt

  @@clone_count = 5

  def initialize(*args)

    @reflekt_forked = false
    @reflekt_clones = []

    # Override methods.
    self.class.instance_methods(false).each do |method|
      self.define_singleton_method(method) do |*args|

        # When method called in flow.
        if @reflekt_forked
          unless self.class.deflekted?(method)
            # Reflekt on method.
            @reflekt_clones.each do |clone|
              reflekt_action(clone, method, *args)
            end
            # Save results.
            @@db.write()
          end
        end

        # Continue method flow.
        super *args
      end

    end

    # Continue contructor flow.
    super

    # Create forks.
    reflekt_fork()

  end

  def reflekt_fork()

    @@clone_count.times do |clone|
      @reflekt_clones << self.clone
    end

    @reflekt_forked = true

  end

  def reflekt_action(clone, method, *args)

    # Create new arguments.
    new_args = []
    args.each do |arg|
      case arg
      when Integer
        new_args << rand(9999)
      else
        new_args << arg
      end
    end

    # Action method with new arguments.
    begin
      clone.send(method, *new_args)
      # Build reflection.
      reflection = {
        "time" => Time.now.to_i,
        "class" => clone.class.to_s,
        "method" => method.to_s,
      }
    # When error.
    rescue StandardError => error
      reflection["status"] = "error"
      reflection["error"] = error
    # When success.
    else
      reflection["status"] = "success"
    end
    # Save reflection.
    @@db.get('reflections')
        .push(reflection)

  end

  private

  # Prepend Klass to the instance's singleton class.
  def self.prepended(base)
    base.singleton_class.prepend(Klass)

    @@setup ||= setup_klass
  end

  # Setup Klass.
  def self.setup_klass()

    # Receive configuration from host application.
    $ENV ||= {}
    $ENV[:reflekt] ||= $ENV[:reflekt] = {}

    # Create "reflections" directory in configured path.
    if $ENV[:reflekt][:output_path]
      dir_path = File.join($ENV[:reflekt][:output_path], 'reflections')
    # Create "reflections" directory in current execution path.
    else
      dir_path = File.join(Dir.pwd, 'reflections')
    end

    unless Dir.exist? dir_path
      Dir.mkdir(dir_path)
    end

    # Create database.
    @@db = Rowdb.new(dir_path + '/db.json')
    @@db.defaults({"reflections" => []})

    return true
  end

  module Klass

    @@deflekted_methods = Set.new

    ##
    # Skip a method.
    #
    # method - A symbol representing the method name.
    ##
    def reflekt_skip(method)
      @@deflekted_methods.add(method)
    end

    def deflekted?(method)
      return true if @@deflekted_methods.include?(method)
      false
    end

  end

end
