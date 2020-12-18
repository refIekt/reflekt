require_relative 'Animal.rb'

class Cat < Animal

  ##
  # It's possible to rename classes and methods without losing past reflections.
  #
  # Example of how to rename this class from Cat to Tiger:
  #   reflekt_rename :class, :Tiger
  #
  # Example of how to rename a method from "meow()" to "roar()":
  #   reflekt_rename :meow, :roar
  #
  # Then when the program runs, old reflections will be updated and reflekt_rename
  # can be removed. However it is recommended to keep it in case another developer
  # is working on the same codebase but using a different machine and database.
  ##

  def meow(message)

    message = message.to_s.downcase + "eeow!"
    talk(message)

  end

  def purr()
    # TODO.
  end

end
