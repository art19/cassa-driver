# encoding: utf-8

require 'bundler/setup'

require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'rake/testtask'
require 'bundler/gem_tasks'

ENV['FAIL_FAST'] ||= 'Y'

RSpec::Core::RakeTask.new(rspec: :compile)

# We separate interactive from non-interactive features because jruby 9k sometimes has trouble
# closing its pipe to the child process in interactive features.

Cucumber::Rake::Task.new({ cucumber_interactive: :compile }, 'Run cucumber features that are interactive') do |t|
  t.profile = 'interactive'
end

Cucumber::Rake::Task.new({ cucumber_noninteractive: :compile }, 'Run cucumber features that are non-interactive') do |t|
  t.profile = 'non_interactive'
end

desc 'Run cucumber features'
task cucumber: [:cucumber_noninteractive, :cucumber_interactive]

desc 'Run all tests'
task test: [:rspec, :integration, :cucumber]

ruby_engine = defined?(RUBY_ENGINE) ? RUBY_ENGINE : 'ruby'

case ruby_engine
when 'jruby'
  require 'rake/javaextensiontask'

  Rake::JavaExtensionTask.new('cassandra_murmur3')
else
  require 'rake/extensiontask'

  Rake::ExtensionTask.new('cassandra_murmur3')
end

Rake::TestTask.new(integration: :compile) do |t|
  t.libs.push 'lib'
  t.libs.push 'support'
  t.libs.push 'integration'
  t.test_files = FileList['integration/*_test.rb',
                          'integration/security/*_test.rb',
                          'integration/load_balancing/*_test.rb',
                          'integration/types/*_test.rb',
                          'integration/functions/*_test.rb',
                          'integration/indexes/*_test.rb']
  t.verbose = true
end

Rake::TestTask.new(stress: :compile) do |t|
  t.libs.push 'lib'
  t.test_files = FileList['integration/stress_tests/*_test.rb']
  t.verbose = true
end

desc 'Build the package and publish it to rubygems.pkg.github.com'
task publish: :build do
  # Requires local setup of personal access token, see:
  # 1. https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-rubygems-registry#authenticating-with-a-personal-access-token
  system("gem push --key github --host https://rubygems.pkg.github.com/art19 " \
         "pkg/cassandra-driver-#{Cassandra::VERSION}.gem")
end


