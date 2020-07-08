module Reflekt

  def initialize(*args)

    puts "--- Constructor. ---"

    self.class.instance_methods(false).each do |method|

      self.define_singleton_method(method) do |*args|

        puts "--- Method. ---"
        p method
        p args

        super *args
      end

    end

    super
  end

  def self.prepended(mod)
    puts "#{self} prepended to #{mod}"
  end

end
