# fluent-plugin-conditional-tag-rewrite

Conditional Tag Rewrite for [Fluentd](https://fluentd.org/) is designed to re-emit records with a different tag.
Multiple AND-conditions can be defined; if all AND-conditions match, the records will be re-emitted with the specified
tag.

## Installation

### RubyGems

```
$ gem install fluent-plugin-conditional-tag-rewrite
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-conditional-tag-rewrite"
```

And then execute:

```
$ bundle
```

## Copyright

* Copyright(c) 2021- Christian Schulz
* License: MIT
