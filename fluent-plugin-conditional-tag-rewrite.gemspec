# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = 'fluent-plugin-conditional-tag-rewrite'
  spec.version = '0.1.0'
  spec.authors = ['Christian Schulz']
  spec.email   = ['trutty3@gmail.com']

  spec.summary       = 'Conditional Tag Rewrite is designed to re-emit records with a different tag. Multiple AND-conditions can be defined; if a set of AND-conditions match, the records will be re-emitted with the specified tag.'
  spec.homepage      = 'https://github.com/trutty/luent-plugin-conditional-tag-rewrite'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split("\n")
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.2.2'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'test-unit', '~> 3.0'
  spec.add_runtime_dependency 'fluentd', ['>= 0.14.10', '< 2']
end
