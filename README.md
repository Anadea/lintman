# Lintman

TODO: Write a description

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lintman', github: 'anadea/lintman', group: %w(development test)
```

And then execute:

```bash
$ bundle
$ rails lintman:install
```

## How to use the lintman?

By executing the command below, you'll get a list of commands that will allow you to launch either all the tools at a time or launch every single tool separately.

```bash
$ rails --tasks lintman

rails lintman:all                  # Run ALL linters
rails lintman:brakeman             # Run brakeman
rails lintman:bundler_audit        # Run bundler_audit
rails lintman:fasterer             # Run fasterer
rails lintman:i18n_tasks           # Run i18n_tasks
rails lintman:install              # Install lintman
rails lintman:lol_dba              # Run lol_dba
rails lintman:railroady            # Generate UML diagrams
rails lintman:rails_best_practices # Run rails_best_practices
rails lintman:rails_erd            # Generate ER-diagram
rails lintman:reek                 # Run reek
rails lintman:rubocop              # Run rubocop
rails lintman:rubycritic           # Run rubycritic
rails lintman:stats                # Report code statistics (KLOCs, etc) from the application or engine
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
