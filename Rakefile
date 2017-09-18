require 'rspec/core/rake_task'

# our rspec runner is configured from the .rspec file
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = Dir.glob('fastlane/spec/**/*_spec.rb')
end

# our rubocop runner is configured from the .rubocop.yml file
require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop) do |t|
  t.patterns = ['fastlane/**/*.rb', 'fastlane/Fastfile']
end

# by default, with no options, rake will run these 2 tasks
task default: %i[spec rubocop]
