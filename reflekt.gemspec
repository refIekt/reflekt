Gem::Specification.new do |spec|

  spec.name        = 'reflekt'
  spec.version     = '0.9.8'
  spec.date        = '2020-11-19'
  spec.authors     = ["Maedi Prichard"]
  spec.email       = 'maediprichard@gmail.com'

  spec.summary     = "Reflective testing."
  spec.description = "Testing that's completely automated."
  spec.homepage    = 'https://github.com/refIekt/reflekt'
  spec.license     = 'MPL-2.0'

  spec.files = [
    "lib/Accessor.rb",
    "lib/Aggregator.rb",
    "lib/Control.rb",
    "lib/Execution.rb",
    "lib/Reflection.rb",
    "lib/Reflekt.rb",
    "lib/Renderer.rb",
    "lib/Rule.rb",
    "lib/RuleSet.rb",
    "lib/ShadowStack.rb",
    "lib/rules/IntegerRule.rb",
    "lib/rules/StringRule.rb",
    "lib/web/bundle.js",
    "lib/web/gitignore.txt",
    "lib/web/index.html",
    "lib/web/package-lock.json",
    "lib/web/package.json",
    "lib/web/README.md",
    "lib/web/server.js"
  ]
  spec.require_paths = ["lib"]

  spec.add_dependency "rowdb"

end
