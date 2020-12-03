require_relative 'Cat.rb'
require_relative 'Dog.rb'
require_relative 'Place.rb'

##
# Configure Reflekt.
##

Reflekt.configure do |config|

  # Reflekt is enabled by default and should be disabled on production.
  config.enabled = true

  # The amount of reflections to create per method call.
  # A control reflection is created in addition to this.
  config.reflect_amount = 2

end

##
# They meet on a city street.
##

street = Place.new("City Street")

cat = Cat.new()
cat.meow("Hi there dog")

dog = Dog.new()
dog.bark("Hello cat")

##
# They are friendly to each other.
##

if cat.is_friendly() && dog.is_friendly()

  ##
  # They show affection.
  ###

  #cat.purr()
  #dog.lick(cat)

  ##
  # They fall in love.
  ##

  ##
  # Their family don't approve.
  ##

  ##
  # They run away together.
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
