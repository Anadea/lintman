require 'io/console'

namespace :lintman do
  task :create_configs do
    configs = [
      { analyzer: 'RSpec',      file: '.rspec' },
      { analyzer: 'Rails ERD',  file: '.erdconfig' },
      { analyzer: 'Rubocop',    file: '.rubocop.yml' },
      { analyzer: 'Reek',       file: '.reek.yml' },
      { analyzer: 'Fasterer',   file: '.fasterer.yml' },
      { analyzer: 'RubyCritic', file: '.rubycritic.yml' }
    ]

    configs.each do |config|
      file_name_without_extension = config[:file][/^\.\w+/]

      # Find existing configs (for example: .reek.yml, .rspec)
      if Dir.glob("#{file_name_without_extension}{.*,}").any?
        puts "Use existing config for #{config[:analyzer]}. "
      else
        print "Creating config for #{config[:analyzer]}... "

        configs_dir = File.join(File.dirname(__dir__), 'configs')
        cp File.join(configs_dir, config[:file]), Dir.pwd, preserve: true, verbose: false

        puts 'Done!'.green
      end
    end

    mkdir_p File.join(Dir.pwd, 'doc'), verbose: false

    puts
  end

  task :install_bullet do
    file = File.join(Dir.pwd, 'config', 'environments', 'development.rb')
    content = File.read(file)

    unless content.match?(/Bullet/)
      print 'Creating config for Bullet... '

      config = <<~BULLET
        config.after_initialize do
          Bullet.tap do |bullet|
            bullet.enable = true
            bullet.alert = false
            bullet.bullet_logger = true
            bullet.console = false
            bullet.growl = false
            bullet.rails_logger = true
            bullet.add_footer = false
            bullet.airbrake = false
          end
        end
      BULLET

      config = config.split("\n").map { |l| l.prepend(' ' * 2) }.join("\n")

      File.write(file, content.gsub(/^end/, "\n#{config}\nend"))

      puts 'Done!'.green

      puts
    end
  end

  task :install_simplecov do
    file = File.join(Dir.pwd, 'spec', 'rails_helper.rb')
    content = File.readlines(file)

    if content.index { |line| line.match?(/simplecov/) }.nil?
      print 'Creating config for Simplecov... '

      index = content.index { |line| line.match?(/abort/) }

      config = <<~SIMPLECOV
        require 'simplecov'

        if ENV['COVERAGE']
          SimpleCov.start 'rails' do
            coverage_dir File.join('doc', 'coverage')

            groups = %w[
              controllers
              forms
              graphql
              interactors
              jobs
              libs
              mailers
              models
              policies
              queries
              requests
              serializers
              services
              tasks
              uploaders
            ]

            groups.each { |name| add_group name.capitalize, "/app/\#{name}" }

            # Default files
            add_filter 'app/jobs/application_job.rb'
            add_filter 'app/mailers/application_mailer.rb'
            add_filter 'app/channels/application_cable/channel.rb'
            add_filter 'app/channels/application_cable/connection.rb'
            add_filter 'app/policies/application_policy.rb'

            add_filter 'app/admin/'
            add_filter 'config/'
            add_filter 'spec/'
          end
        end

      SIMPLECOV

      File.write(file, content.insert(index + 2, config.lines).flatten.join)

      puts 'Done!'.green
      puts
    end
  end

  task :info do
    box 'Important!', color: :red do
      <<~INFO
        You need to install the following utilites:

        On MacOS:

          $ brew install graphviz

        On Linux:

          $ apt-get install graphviz
      INFO
    end

    puts

    box 'How to use'

    puts <<~INFO
      You can run all linters using this command:

        $ rails lintman:all

      Check output into the console and go to the <project_root>/doc directory.
      There you will find diagrams and some reports in html format.

      If you want to see test coverage report you need to run tests first:

        $ rspec

      For more information see:

        $ rails -T lintman
    INFO

    puts
  end

  desc 'Install lintman'
  task :install do
    box 'lintman'

    %w[create_configs install_bullet install_simplecov info].each do |task|
      Rake::Task["lintman:#{task}"].invoke
    end
  end

  # Diagrams ----------------------------------------------------------------------------------------------------------

  desc 'Generate ER-diagram'
  task :rails_erd do
    system 'bundle exec erd'
  end

  desc 'Generate UML diagrams'
  task :railroady do
    puts 'Processing Models...'

    common_options = '--alphabetize --inheritance --show-belongs_to'

    system "bundle exec railroady #{common_options} --brief --output doc/models-brief.dot --models"
    system 'dot -T svg doc/models-brief.dot > doc/models-brief.svg'

    system "bundle exec railroady #{common_options} --all-columns --output doc/models.dot --models"
    system 'dot -T svg doc/models.dot > doc/models.svg'

    puts 'Processing Controllers...'

    system 'bundle exec railroady --engine-controllers --output doc/controllers.dot --controllers'
    system 'neato -T svg doc/controllers.dot > doc/controllers.svg'

    system 'rm doc/*.dot'
  end

  # Linters -----------------------------------------------------------------------------------------------------------

  tasks = {
    bundler_audit: {
      command: 'bundle audit check --update'
    },
    reek: {
      command: 'bundle exec reek -c .reek.yml'
    },
    rubocop: {
      command: 'bundle exec rubocop'
    },
    rails_best_practices: {
      command: 'bundle exec rails_best_practices --config .rails_best_practices.yml --silent --exclude "db/migrate"'
    },
    rubycritic: {
      command: 'bundle exec rubycritic -f html -f console --no-browser --path doc/rubycritic app config lib'
    },
    fasterer: {
      command: 'bundle exec fasterer'
    },
    brakeman: {
      command: 'bundle exec brakeman -q'
    },
    i18n_tasks: {
      command: 'bundle exec i18n-tasks health'
    },
    lol_dba: {
      command: 'bundle exec rails db:find_indexes'
    },
  }

  tasks.each do |name, command:|
    desc "Run #{name}"
    task name.to_sym, [:return_exitcode] => :environment do |_, args|
      system command

      raise unless args.return_exitcode || $?.success?
    end
  end

  # -------------------------------------------------------------------------------------------------------------------

  desc 'Report code statistics (KLOCs, etc) from the application or engine'
  task :stats do
    require 'rails/code_statistics'

    code = [
      ['Decorators',  'app/decorators'],
      ['Forms',       'app/forms'],
      ['Interactors', 'app/interactors'],
      ['Jobs',        'app/jobs'],
      ['Policies',    'app/policies'],
      ['Queries',     'app/queries'],
      ['Serializers', 'app/serializers'],
      ['Services',    'app/services'],
      ['Uploaders',   'app/uploaders'],
      ['Validators',  'app/validators'],
      ['Values',      'app/values'],
      ['Views',       'app/views']
    ]

    code.each do |item|
      ::STATS_DIRECTORIES << item if Dir.exist?(File.join(Dir.pwd, item.last))
    end

    specs = [
      ['Spec: Channels',    'spec/channels'],
      ['Spec: Controllers', 'spec/controllers'],
      ['Spec: Decorators',  'spec/decorators'],
      ['Spec: Factories',   'spec/factories'],
      ['Spec: Features',    'spec/features'],
      ['Spec: Forms',       'spec/forms'],
      ['Spec: Helpers',     'spec/helpers'],
      ['Spec: Interactors', 'spec/interactors'],
      ['Spec: Jobs',        'spec/jobs'],
      ['Spec: Libs',        'spec/libs'],
      ['Spec: Mailers',     'spec/mailers'],
      ['Spec: Models',      'spec/models'],
      ['Spec: Policies',    'spec/policies'],
      ['Spec: Queries',     'spec/queries'],
      ['Spec: Requests',    'spec/requests'],
      ['Spec: Serializers', 'spec/serializers'],
      ['Spec: Services',    'spec/services'],
      ['Spec: Tasks',       'spec/tasks'],
      ['Spec: Uploaders',   'spec/uploaders'],
      ['Spec: Values',      'spec/values'],
      ['Spec: Views',       'spec/views']
    ]

    specs.each do |item|
      if Dir.exist?(File.join(Dir.pwd, item.last))
        ::STATS_DIRECTORIES << item
        CodeStatistics::TEST_TYPES << item.first
      end
    end

    Rake::Task['stats'].invoke
  end

  desc 'Run ALL linters'
  task :all do
    %w[
      bundler_audit
      reek
      rubocop
      rails_best_practices
      rubycritic
      fasterer
      brakeman
      i18n_tasks
      lol_dba
      rails_erd
      railroady
      stats
    ].each do |task|
      box task

      Rake::Task["lintman:#{task}"].invoke(true)

      puts
    end
  end

  def box(text, header_color: :yellow, color: :default)
    puts "-- #{text.upcase} #{'-' * (IO.console.winsize.last - text.length - 4)}\n".colorize(header_color)

    return unless block_given? && yield.is_a?(String)

    puts yield.colorize(color)
  end
end
