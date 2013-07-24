module Mongoid
  module Preferences
    module Preferenceable
      extend ActiveSupport::Concern

      included do

        field :preferences, :type => Hash, :default => Proc.new { HashWithIndifferentAccess.new() }

        after_initialize :load_preferences

        # Returns all the preferences
        def preferences
          @_prefs ||= merged_preferences
        end

        # Returns the value of preference or nil if the preference is not found
        def pref(name)
          self.preferences[name]
        end

        # Retruns true if the model has the preference, else returns false
        def has_pref?(name)
          return false unless self.preferences.has_key?(name)
          true
        end

        # Set the value of specified preference or add a new preference, and returns the value
        def write_pref(name, value)
          #override the preference value or add new preference if not exist
          preferences[name] = value
          write_attribute(:preferences, preferences)
          value
        end

        # Returns an array of hash of preferences
        def displayable_preferences(group)
          default_preferences_hash = default_preferences
          if default_preferences_hash.has_key?(group)
            default_preferences_hash[group][:preferences].each do |preference|
              name = preference[:name]
              if self.preferences.has_key?(name)
                # overwrite default preference value with the model preference value
                preference[:value] = self.preferences[name]
              end
            end
            default_preferences_hash[group][:preferences]
          else
            nil
          end
        end

        private

        def load_preferences
          if read_attribute(:preferences).blank?
            write_attribute(:preferences, preferences)
          end
        end

        # Returns a hash of default preferences loaded from file
        def default_preferences
          return self.class.class_variable_get :@@default_preferences if self.class.class_variable_defined? :@@default_preferences

          default_preferences_path = File.join(Preferences.model_preferences_path, "#{self.class.name.downcase}.yml")

          if File.exist?(default_preferences_path)
            self.class.class_variable_set :@@default_preferences, HashWithIndifferentAccess.new(YAML.load_file(default_preferences_path)) # for access with symbols
          else
            logger.error "PreferencesModelError##{self.class.name}: File not found"
            self.class.class_variable_set :@@default_preferences, {}
          end
        end

        # Returns a hash of preferences merged from file and model
        def merged_preferences
          # get the preferences from model
          model_preferences_hash = HashWithIndifferentAccess.new(self.read_attribute(:preferences))
          # get the default preferences form file
          default_preferences_hash = default_preferences
          # merge the preferences
          default_preferences_hash.each_key do |key|
            default_preferences_hash[key][:preferences].each do |preference|
              name = preference[:name]
              default_value = preference[:value]
              # if the preference on model does not exist
              unless model_preferences_hash.has_key? name
                # add the new preference(read from file) to the model preferences hash
                model_preferences_hash[name] = default_value
              end
            end
          end
          model_preferences_hash
        end

      end
    end
  end
end