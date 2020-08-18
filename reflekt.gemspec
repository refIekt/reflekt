Gem::Specification.new do |spec|

  spec.name        = 'reflekt'
  spec.version     = '0.1.3'
  spec.date        = '2020-07-18'
  spec.authors     = ["Maedi Prichard"]
  spec.email       = 'maediprichard@gmailcom'

  spec.summary     = "Reflective testing that's completely automated."
  spec.description = "Reflective testing that's completely automated."
  spec.homepage    = 'https://github.com/maedi/reflekt'
  spec.license     = 'MPL-2.0'

  spec.files         = ["lib/reflekt.rb"]
  spec.require_paths = ["lib"]

  spec.add_dependency "rowdb"

end
