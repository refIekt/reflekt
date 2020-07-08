################################################################################
# REFLEKT
#
# Must be defined before the class its included in with:
# "prepend Reflekt"
################################################################################

module Reflekt

  def initialize(*args)

    # Override methods.
    self.class.instance_methods(false).each do |method|
      self.define_singleton_method(method) do |*args|

        # When method called.
        unless @reflekt_clone == nil
          # Reflekt on method.
          @reflekt_clone.send(method, *args)
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

  def self.prepended(mod)
    puts "#{self} prepended to #{mod}"
  end

end
