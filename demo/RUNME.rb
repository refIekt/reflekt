require_relative 'Location.rb'
require_relative 'Cat.rb'
require_relative 'Dog.rb'

##
# They meet on a city street.
##

street = Location.new("City Street")

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

  cat.purr()
  dog.lick(cat)

  ##
  # They fall in love.
  ##

  ##
  # Their family don't approve.
  ##

  ##
  # They run away together.
  ###

  locations = []
  paris = Location.new("Paris")
  berlin = Location.new("Berlin")
  madrid = Location.new("Madrid")

  locations << paris
  locations << berlin
  locations << madrid

else

  ##
  # They part ways.
  ##

end
