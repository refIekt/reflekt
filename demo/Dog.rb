require_relative 'Animal.rb'

class Dog < Animal

  def bark(message)

    message = message.upcase + "!!"
    talk(message)

  end

  def lick()

  end

end
