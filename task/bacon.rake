desc "Runs bacon tests with code coverage"
task :bacon do
  require 'simplecov'
  require 'bacon'

  Bacon.const_set :Backtraces, false unless ENV['BACON_MUTE'].nil? 

  SimpleCov.command_name 'bacon'
  SimpleCov.start do
    add_filter "spec/"
    add_filter "vendor/"
    add_filter "config"
  end if ENV["COVERAGE"] 

  require File.expand_path('spec/ramaze_fnordmetric/fnordmetric.rb')
end
