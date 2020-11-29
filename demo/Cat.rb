require_relative 'Animal.rb'

class Cat < Animal

  def meow(message)

    message = message.downcase + "eeow!"
    talk(message)

  end

  def purr()

  end

end
