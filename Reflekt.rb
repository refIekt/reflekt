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
  @@deflekted_methods = Set.new

  def initialize(*args)

    # Override methods.
    self.class.instance_methods(false).each do |method|
      self.define_singleton_method(method) do |*args|

        # When method called in flow. (because it was cloned first pass through)
        unless @reflekt_clone == nil
          unless method_deflekted?(@reflekt_clone, method)
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

  ##
  # Don't reflekt every method.
  #
  # method - A symbol representing the method name.
  ##
  def self.deflekt(method)
    @@deflekted_methods.add(method)
  end

  def method_deflekted?(reflekt_clone, method)
    return true if @@deflekted_methods.include?(method)
    false
  end

  def self.prepended(mod)
    puts "#{self} prepended to #{mod}"
  end

end
