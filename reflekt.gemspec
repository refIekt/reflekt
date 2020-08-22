Gem::Specification.new do |spec|

  spec.name        = 'reflekt'
  spec.version     = '0.5.0'
  spec.date        = '2020-07-22'
  spec.authors     = ["Maedi Prichard"]
  spec.email       = 'maediprichard@gmailcom'

  spec.summary     = "Reflective testing."
  spec.description = "Testing that's completely automated."
  spec.homepage    = 'https://github.com/maedi/reflekt'
  spec.license     = 'MPL-2.0'

  spec.files         = ["lib/reflekt.rb", "lib/web/template.html.erb", "lib/web/alpine.js"]
  spec.require_paths = ["lib"]

  spec.add_dependency "rowdb"

end
