require 'mongoid-preferences/preferences/preferenceable'
require 'mongoid-preferences/preferences/version'

module Mongoid
  module Preferences
    include ActiveSupport::Configurable
    config_accessor :model_preferences_path
  end
end

###
# Use this code into an initializer for configure the path of preferences yaml
##

#Mongoid::Preferences.configure do |config|
#  # set default preferences path
#  config.model_preferences_path = Rails.root.join('app','models_preferences')
#end
