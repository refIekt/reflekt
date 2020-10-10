Gem::Specification.new do |spec|

  spec.name        = 'reflekt'
  spec.version     = '0.9.6'
  spec.date        = '2020-10-07'
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
    "lib/Reflekt.rb",
    "lib/Renderer.rb",
    "lib/Rule.rb",
    "lib/RulePool.rb",
    "lib/Ruler.rb",
    "lib/ShadowStack.rb",
    "lib/rules/FloatRule.rb",
    "lib/rules/IntegerRule.rb",
    "lib/rules/StringRule.rb",
    "lib/web/template.html.erb",
    "lib/web/style.css",
    "lib/web/script.js"
  ]
  spec.require_paths = ["lib"]

  spec.add_dependency "rowdb"

end
