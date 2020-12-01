Gem::Specification.new do |spec|

  spec.name        = 'reflekt'
  spec.version     = '0.9.91'
  spec.date        = '2020-12-01'
  spec.authors     = ["Maedi Prichard"]
  spec.email       = 'maediprichard@gmail.com'

  spec.summary     = "Reflective testing."
  spec.description = "Testing that's completely automated."
  spec.homepage    = 'https://github.com/refIekt/reflekt'
  spec.license     = 'MPL-2.0'

  spec.files = [
    # Core.
    "lib/Accessor.rb",
    "lib/Aggregator.rb",
    "lib/Clone.rb",
    "lib/Config.rb",
    "lib/Control.rb",
    "lib/Execution.rb",
    "lib/MetaBuilder.rb",
    "lib/Meta.rb",
    "lib/Reflection.rb",
    "lib/Reflekt.rb",
    "lib/Renderer.rb",
    "lib/Rule.rb",
    "lib/RuleSet.rb",
    "lib/ShadowStack.rb",
    # Meta.
    "lib/meta/ArrayMeta.rb",
    "lib/meta/BooleanMeta.rb",
    "lib/meta/IntegerMeta.rb",
    "lib/meta/StringMeta.rb",
    # Rules.
    "lib/rules/ArrayRule.rb",
    "lib/rules/BooleanRule.rb",
    "lib/rules/IntegerRule.rb",
    "lib/rules/StringRule.rb",
    # UI.
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
