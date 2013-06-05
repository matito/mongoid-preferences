$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
MODELS = File.join(File.dirname(__FILE__), "models")

require 'coveralls'
Coveralls.wear!

require 'rubygems'
require 'bundler/setup'

require 'rspec'
require 'mongoid'
require 'mongoid-preferences'
require 'database_cleaner'
require 'mongoid-rspec'
require 'pathname'

Dir["#{MODELS}/*.rb"].each { |f| require f }

Mongoid.configure do |config|
  config.connect_to "mongoid_preferences"
end

Mongoid.logger = Logger.new($stdout)

DatabaseCleaner.orm = "mongoid"

RSpec.configure do |config|
  config.include Mongoid::Matchers

  config.before(:all) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

#Helper method for setting the RIGHT path for the preferences file
def set_right_preferences_path
  Mongoid::Preferences.configure do |config|
    # model preferences path to dummy model
    config.model_preferences_path = File.join(File.dirname(__FILE__), "models_preferences")
  end
end

#Helper method for setting the WRONG path for the preferences file
def set_wrong_preferences_path
  Mongoid::Preferences.configure do |config|
    # model preferences path to dummy model
    config.model_preferences_path = 'wrong/path/to/preferences/file'
  end
end
