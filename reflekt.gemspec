Gem::Specification.new do |spec|

  spec.name        = 'reflekt'
  spec.version     = '0.1.0'
  spec.date        = '2020-07-18'
  spec.authors     = ["Maedi Prichard"]
  spec.email       = 'maediprichard@gmailcom'

  spec.summary     = "Reflection-driven development."
  spec.description = "Reflection-driven development via reflection testing."
  spec.homepage    = 'https://github.com/maedi/reflekt'
  spec.license     = 'MPL-2.0'

  spec.files         = ["lib/reflekt.rb", "lib/rehash.rb"]
  spec.require_paths = ["lib"]

  spec.add_dependency "oj"

end
