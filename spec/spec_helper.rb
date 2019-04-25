require 'bundler/setup'
require 'fuubar'
require 'lintman'

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.order = :random

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.fuubar_progress_bar_options = {
    format: '[ %c/%C | %p%% ] [%b%i] [ %a | %e ]',
    progress_mark: '#',
    remainder_mark: '-',
    starting_at: 10
  }

  Kernel.srand config.seed
end
