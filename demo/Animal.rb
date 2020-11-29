require 'reflekt'

class Animal

  prepend Reflekt

  # TODO: Fix.
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

  end

  ##
  # @param animal [Animal] The other animal to run away with.
  def run_away(animal)

  end

end
