require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = Dir.glob('fastlane/spec/**/*_spec.rb')
end

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop) do |t|
  t.patterns = ['fastlane/**/*.rb', 'fastlane/Fastfile']
end

task default: %i[spec rubocop]
