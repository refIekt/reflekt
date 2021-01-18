require_relative 'animal'

class Cat < Animal

  ##
  # TODO: Implement rename feature.
  # It's possible to rename classes and methods without losing past reflections.
  #
  # Example of how to rename this class from Cat to Tiger:
  #   reflekt_rename :class, :Tiger
  #
  # Example of how to rename a method from "meow()" to "roar()":
  #   reflekt_rename :meow, :roar
  #
  # Then when the program runs, old reflections will be updated.
  ##

  def meow(message)
    message = message.to_s.downcase + "eeow!"
    talk(message)
  end

  def is_friendly()
    false
  end

end
