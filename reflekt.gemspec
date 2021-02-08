Gem::Specification.new do |spec|

  spec.name        = 'reflekt'
  spec.version     = '1.0.10'
  spec.date        = '2021-02-08'
  spec.authors     = ["Maedi Prichard"]
  spec.email       = 'maediprichard@gmail.com'

  spec.summary     = "Reflective testing."
  spec.description = "Testing that's completely automated."
  spec.homepage    = 'https://reflekt.dev'
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
    "lib/meta/array_meta.rb",
    "lib/meta/boolean_meta.rb",
    "lib/meta/float_meta.rb",
    "lib/meta/integer_meta.rb",
    "lib/meta/null_meta.rb",
    "lib/meta/object_meta.rb",
    "lib/meta/string_meta.rb",
    # Rules.
    "lib/rules/array_rule.rb",
    "lib/rules/boolean_rule.rb",
    "lib/rules/float_rule.rb",
    "lib/rules/integer_rule.rb",
    "lib/rules/null_rule.rb",
    "lib/rules/object_rule.rb",
    "lib/rules/string_rule.rb",
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
  spec.add_dependency "lit-cli"

end
