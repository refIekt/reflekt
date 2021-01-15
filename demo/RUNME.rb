require_relative 'cat'
require_relative 'dog'
require_relative 'place'

##
# Configure Reflekt.
##

Reflekt.configure do |config|

  # Reflekt is enabled by default and should be disabled on production.
  config.enabled = true

  # The amount of experiment reflections to create per method call.
  # A control reflection is created in addition to this.
  config.reflect_amount = 2

end

##
# They meet on a city street.
# @tests Instantiation
##

street = Place.new("City Street")

cat = Cat.new()
cat.meow("Hi there dog")

dog = Dog.new()
dog.bark("Hello cat")

##
# They are friendly to each other.
# @tests Boolean
##

if cat.is_friendly()

  ##
  # They fall in love.
  # @tests Variable assignment
  ##

  cat.fall_in_love(dog)
  dog.fall_in_love(cat)

  ##
  # Their family don't approve.
  # @tests Moves the plot forward
  ##

  FATHER_WHO_NEVER_APPROVES = "I disapprove of your romance and everything!"
  MOTHER_WHO_MAYBE_APPROVES = "I am also pretty critical of new boyfriends."

  cat.meow("Hi mum and dad, this is the love of my life!")
  dog.bark("Nice to meet you folks!")
  puts FATHER_WHO_NEVER_APPROVES
  puts MOTHER_WHO_MAYBE_APPROVES

  ##
  # They run away together.
  # @tests Loops
  ###

  places = []
  places << Place.new("Paris")
  places << Place.new("Berlin")
  places << Place.new("Madrid")

else

  ##
  # They part ways.
  ##

end
