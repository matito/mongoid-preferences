module Mongoid
  module Preferences

    require 'mongoid/preferences/preferenceable'
    require 'mongoid/preferences/version'

    include ActiveSupport::Configurable

    config_accessor :model_preferences_path do
      # default model preferences path
      Rails.root.join('app','models_preferences')
    end


    #Mongoid::Preferences.configure do |config|
    #  # set default preferences path
    #  config.model_preferences_path = Rails.root.join('app','models_preferences')
    #end

  end
end