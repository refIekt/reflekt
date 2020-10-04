Gem::Specification.new do |spec|

  spec.name        = 'reflekt'
  spec.version     = '0.9.3'
  spec.date        = '2020-10-04'
  spec.authors     = ["Maedi Prichard"]
  spec.email       = 'maediprichard@gmailcom'

  spec.summary     = "Reflective testing."
  spec.description = "Testing that's completely automated."
  spec.homepage    = 'https://github.com/refIekt/reflekt'
  spec.license     = 'MPL-2.0'

  spec.files = [
    "lib/Accessor.rb",
    "lib/Control.rb",
    "lib/Execution.rb",
    "lib/Reflection.rb",
    "lib/reflekt.rb",
    "lib/Rule.rb",
    "lib/Ruler.rb",
    "lib/ShadowStack.rb",
    "lib/web/template.html.erb",
    "lib/web/style.css",
    "lib/web/script.js"
  ]
  spec.require_paths = ["lib"]

  spec.add_dependency "rowdb"

end
