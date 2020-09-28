Gem::Specification.new do |spec|

  spec.name        = 'reflekt'
  spec.version     = '0.8.0'
  spec.date        = '2020-07-22'
  spec.authors     = ["Maedi Prichard"]
  spec.email       = 'maediprichard@gmailcom'

  spec.summary     = "Reflective testing."
  spec.description = "Testing that's completely automated."
  spec.homepage    = 'https://github.com/refIekt/reflekt'
  spec.license     = 'MPL-2.0'

  spec.files = [
    "lib/reflekt.rb",
    "lib/Execution.rb",
    "lib/Reflection.rb",
    "lib/ShadowStack.rb",
    "lib/web/template.html.erb",
    "lib/web/style.css",
    "lib/web/script.js"
  ]
  spec.require_paths = ["lib"]

  spec.add_dependency "rowdb"

end
