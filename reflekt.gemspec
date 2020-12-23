Gem::Specification.new do |spec|

  spec.name        = 'reflekt'
  spec.version     = '1.0.6'
  spec.date        = '2020-12-23'
  spec.authors     = ["Maedi Prichard"]
  spec.email       = 'maediprichard@gmail.com'

  spec.summary     = "Reflective testing."
  spec.description = "Testing that's completely automated."
  spec.homepage    = 'https://github.com/refIekt/reflekt'
  spec.license     = 'MPL-2.0'

  spec.files = [
    # Core.
    "lib/accessor.rb",
    "lib/action.rb",
    "lib/action_stack.rb",
    "lib/clone.rb",
    "lib/config.rb",
    "lib/control.rb",
    "lib/experiment.rb",
    "lib/meta_builder.rb",
    "lib/meta.rb",
    "lib/reflection.rb",
    "lib/reflekt.rb",
    "lib/renderer.rb",
    "lib/rule.rb",
    "lib/rule_set.rb",
    "lib/rule_set_aggregator.rb",
    # Meta.
    "lib/meta/ArrayMeta.rb",
    "lib/meta/BooleanMeta.rb",
    "lib/meta/FloatMeta.rb",
    "lib/meta/IntegerMeta.rb",
    "lib/meta/NullMeta.rb",
    "lib/meta/StringMeta.rb",
    # Rules.
    "lib/rules/ArrayRule.rb",
    "lib/rules/BooleanRule.rb",
    "lib/rules/FloatRule.rb",
    "lib/rules/IntegerRule.rb",
    "lib/rules/NullRule.rb",
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
