require_relative '../lib/reflekt'

class Animal

  # Add Reflekt to this class and its children.
  prepend Reflekt

  # Do not reflect the talk() method on this class or its children.
  reflekt_skip :talk

  def initialize()
    @in_love = false
  end

  def talk(sound)
    puts sound
  end

  ##
  # @return [Boolean] Random true or false value.
  ##
  def is_friendly()
    [true, false].sample
  end

  def fall_in_love
    @in_love = true
  end

  def disobey_parents
    # TODO.
  end

  ##
  # @param animal [Animal] The other animal to run away with.
  ##
  def run_away(animal)
    # TODO.
  end

end
