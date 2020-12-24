require_relative 'animal'

class Dog < Animal

  def bark(message)

    message = message.upcase + "!!"
    talk(message)

  end

  def lick()
    # TODO.
  end

end
