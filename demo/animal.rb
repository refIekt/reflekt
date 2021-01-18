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
  #
  # TODO: Whoops, big bug here. If the control reflection uses a random value,
  #       then the actual execution could use a different random value.
  #       The control and the execution need to be synced up. Either track
  #       control random values via methods like ".sample" or add an
  #      "is_random :method" helper for methods that return a random value.
  #       Then keep track of random values and replay them in execution.
  #       The former gets into monkey patching territory, the latter into DSL.
  #
  # SEE:
  #   This can be a random true/false value when this bug fixed:
  #   https://github.com/refIekt/reflekt/issues/6
  #
  # CODE:
  #   [true, false].sample
  ##
  def is_friendly()
    true
  end

  def fall_in_love(animal)
    @in_love = true
    @lover = animal
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
