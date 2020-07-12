require 'set'

################################################################################
# REFLEKT
#
# Must be defined before the class it's included in.
#
#   class ExampleClass
#     prepend Reflekt
################################################################################

module Reflekt

  @reflekt_clone = nil

  def initialize(*args)

    # Override methods.
    self.class.instance_methods(false).each do |method|
      self.define_singleton_method(method) do |*args|

        # When method called in flow.
        unless @reflekt_clone == nil
          unless self.class.method_deflekted?(method)
            # Reflekt on method.
            @reflekt_clone.send(method, *args)
          end
        end

        # Continue method flow.
        super *args
      end

    end

    # Continue contructor flow.
    super

    # Clone methods.
    @reflekt_clone = self.clone

  end

  # Access class methods in the instance's singleton class.
  def self.prepended(base)
    base.singleton_class.prepend(Klass)
  end

  module Klass

    @@deflekted_methods = Set.new

    ##
    # Don't reflekt every method.
    #
    # method - A symbol representing the method name.
    ##
    def deflekt(method)
      @@deflekted_methods.add(method)
    end

    def method_deflekted?(method)
      return true if @@deflekted_methods.include?(method)
      false
    end

  end

end
