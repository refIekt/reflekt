require 'set'
require 'rowdb'

################################################################################
# REFLEKT
#
# Must be defined before the class it's included in.
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
    rescue StandardError => error
      p error
    else
      puts "Success."
    end

  end

  private

  # Prepend Klass to the instance's singleton class.
  def self.prepended(base)
    base.singleton_class.prepend(Klass)

    @@setup ||= setup_klass
  end

  # Setup Klass.
  def self.setup_klass()

    # Create "reflections" directory in current execution path.
    # TODO: Allow global config override of path.
    dir_path = File.join(Dir.pwd, 'reflections')
    unless Dir.exist? dir_path
      Dir.mkdir(dir_path)
    end

    @@db = Rowdb.new(:file_system, dir_path + '/db.json')
    @@db.defaults({items: []})

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
