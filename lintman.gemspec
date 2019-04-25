lib = File.expand_path('lib', __dir__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'lintman/version'

Gem::Specification.new do |spec|
  spec.name        = 'lintman'
  spec.version     = Lintman::VERSION
  spec.authors     = ['Dmitriy Grechukha']
  spec.email       = ['dmitriy.grechukha@gmail.com']

  spec.summary     = 'Lintman cares about the quality of your code.'
  spec.description = 'Lintman cares about the quality of your code.'
  spec.homepage    = 'https://anadea.info'
  spec.license     = 'MIT'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'fuubar'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'

  spec.add_dependency 'awesome_print'
  spec.add_dependency 'benchmark-ips'
  spec.add_dependency 'brakeman'
  spec.add_dependency 'bullet'
  spec.add_dependency 'bundler-audit'
  spec.add_dependency 'colorize'
  spec.add_dependency 'fasterer'
  spec.add_dependency 'hirb'
  spec.add_dependency 'i18n-tasks'
  spec.add_dependency 'lol_dba'
  spec.add_dependency 'pry-byebug'
  spec.add_dependency 'pry-rails'
  spec.add_dependency 'pry-rescue'
  spec.add_dependency 'pry-stack_explorer'
  spec.add_dependency 'railroady'
  spec.add_dependency 'rails-erd'
  spec.add_dependency 'rails_best_practices'
  spec.add_dependency 'reek'
  spec.add_dependency 'rubocop'
  spec.add_dependency 'rubocop-performance'
  spec.add_dependency 'rubocop-rspec'
  spec.add_dependency 'rubycritic'
  spec.add_dependency 'simplecov'
end
