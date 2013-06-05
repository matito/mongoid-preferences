require 'spec_helper'

describe Mongoid::Preferences::Preferenceable do

  let(:file_default_preferences_hash) {
    HashWithIndifferentAccess.new( YAML.load_file(File.join(File.dirname(__FILE__),
                                                            'models_preferences',
                                                            'dummy',
                                                            'default_preferences.yml')))
  }

  let(:view_preferences_hash) { file_default_preferences_hash[:view][:preferences] }

  let(:default_preferences_hash) {
    # remove the type key form preferences
    preferences_hash = HashWithIndifferentAccess.new()
    file_default_preferences_hash[:view][:preferences].each { |p|
      preferences_hash[p[:name]] = p[:value]
    }
    preferences_hash
  }

  let(:custom_preferences_hash) { HashWithIndifferentAccess.new ({'pref1' => false, 'pref2' => false, 'pref3' => false})}

  let(:merged_preferences_hash) {
    # returns an hash of preferences (merge between custom and default) with format {key => value, ecc..}
    default_preferences_hash.merge(custom_preferences_hash)
  }

  # Instance that has saved preferences
  let(:model_with_preferences) {
    Dummy.new(:preferences => merged_preferences_hash)
  }

  # Instance with empty preferences hash
  let(:model_with_empty_preferences) { Dummy.new }

  before :each do
    # Clear cached preferences
    Dummy.remove_class_variable(:@@default_preferences) if Dummy.class_variable_defined? :@@default_preferences
  end

  describe '#default_preferences' do

    context 'when default preferences file found' do
      before { set_right_preferences_path }
      it 'returns a hash with the default preferences' do
        # Use send method for testing private method
        expect(model_with_empty_preferences.send(:default_preferences)).to eq(file_default_preferences_hash)
      end
    end

    context 'when default preferences file not found' do
      before { set_wrong_preferences_path }
      it 'returns an empty hash' do
        # Use send method for testing private method
        expect(model_with_empty_preferences.send(:default_preferences)).to be_empty
      end
    end

  end

  describe '#write_pref' do


    it 'returns the value of preference' do
      expect(model_with_preferences.write_pref(:custom_pref, false)).to be_false
    end

    context 'when default preferences file found' do

      before { set_right_preferences_path }

      context 'when add a new custom preference' do
        it 'has a hash of preferences which include the new preference' do
          new_pref_key = 'custom_pref'
          new_pref_value = false
          model_with_preferences.write_pref(new_pref_key, new_pref_value)
          model_with_preferences.save
          expect(model_with_preferences.preferences).to include(new_pref_key)
        end
      end

      context 'when change the value of a default preference' do
        it 'has a hash of preferences with default preference changed in value' do
          default_pref_key = 'show_tabs_control'
          # Change the default value from true to false
          new_default_pref_value = false
          model_with_preferences.write_pref(default_pref_key, new_default_pref_value)
          model_with_preferences.save
          expect(model_with_preferences.preferences[default_pref_key]).to eq(new_default_pref_value)
        end
      end
      context 'when add a new preference for another instance' do
        before {
          @new_pref_key = 'new_pref'
          @new_pref_value = true
          @new_instance = Dummy.new
          @new_instance.write_pref(@new_pref_key, @new_pref_value)
          @new_instance.save
        }
        it 'new instance include the new preference' do
          expect(@new_instance.preferences).to include(@new_pref_key)
        end
        it 'existing instance does not include the new preference' do
          expect(model_with_preferences.preferences).to_not include(@new_pref_key)
        end
      end
      context 'when change the value of a default preference for another instance' do
        before {
          @default_pref_key = 'show_tabs_control'
          # Change the default value from true to false
          @new_default_pref_value = false
          @new_instance = Dummy.new
          @new_instance.write_pref(@default_pref_key, @new_default_pref_value)
          @new_instance.save
        }
        it 'new instance has a default preference changed in value' do
          expect(@new_instance.preferences[@default_pref_key]).to eq(@new_default_pref_value)
        end
        it 'existing instance has a default preference not changed in value' do
          expect(model_with_preferences.preferences[@default_pref_key]).to_not eq(@new_default_pref_value)
        end

      end

    end

    context 'when default preferences file not found' do

      before { set_wrong_preferences_path }

      context 'when add a new custom preference' do
        it 'has a hash of preferences which include the new preference' do
          new_pref_key = 'custom_pref'
          new_pref_value = false
          model_with_empty_preferences.write_pref(new_pref_key, new_pref_value)
          model_with_empty_preferences.save
          expect(model_with_empty_preferences.preferences).to include(new_pref_key)
        end
      end

      context 'when add a new preference for another instance' do
        before {
          @new_pref_key = 'new_pref'
          @new_pref_value = true
          @new_instance = Dummy.new
          @new_instance.write_pref(@new_pref_key, @new_pref_value)
          @new_instance.save
        }
        it 'new instance include the new preference' do
          expect(@new_instance.preferences).to include(@new_pref_key)
        end
        it 'existing instance does not include the new preference' do
          expect(model_with_empty_preferences.preferences).to_not include(@new_pref_key)
        end
      end

    end

  end


  describe '#preferences' do

    context 'when default preferences file not found' do

      before { set_wrong_preferences_path }

      context 'when model has empty preferences' do
        it 'returns an empty hash' do
          expect(model_with_empty_preferences.preferences).to be_empty
        end
      end

      context 'when model has preferences' do
        it 'returns a hash with merged preferences' do
          expect(model_with_preferences.preferences).to eq(merged_preferences_hash)
        end
      end

    end

    context 'when default preferences file found' do

      before { set_right_preferences_path }

      context 'when model has empty preferences' do
        it 'returns a hash with default preferences' do
          expect(model_with_empty_preferences.preferences).to eq(default_preferences_hash)
        end
      end

      context 'when model has preferences' do
        it 'returns a hash with merged preferences' do
          expect(model_with_preferences.preferences).to eq(merged_preferences_hash)
        end
      end

    end
  end

  describe '#pref' do

    context 'when preference exist' do
      it 'returns the preference value' do
        expect(model_with_preferences.pref(:show_tabs_control)).to eq(true)
      end
    end

    context 'when preference not exist' do
      it 'returns nil' do
        expect(model_with_preferences.pref(:wrong_pref)).to be_nil
      end
    end

  end

  describe '#displayable_preferences' do

    context 'when default preferences file found' do

      before { set_right_preferences_path }

      context 'when preferences group exist' do
        it 'returns a hash of preferences for the group' do
          expect(model_with_empty_preferences.displayable_preferences(:view)).to eq(view_preferences_hash)
        end

        context 'when change the value of preference' do

          before {
            @default_pref_key = 'show_wall_page'
            @new_pref_value = false
            # change the value from true to false
            model_with_empty_preferences.write_pref(:show_wall_page, false)
            model_with_empty_preferences.save
          }

          it 'returns a hash which include the preference changed in value' do
            #expect(model_with_empty_preferences.displayable_preferences(:view_preferences)[@default_pref_key]).

          end

        end
      end

      context 'when preferences group not exist' do
        it 'returns nil' do
          expect(model_with_empty_preferences.displayable_preferences(:wrong_group)).to be_nil
        end
      end

    end

    context 'when default preferences file not found' do

      before { set_wrong_preferences_path }

      context 'when preferences group exist' do
        it 'returns nil' do
          expect(model_with_empty_preferences.displayable_preferences(:view)).to be_nil
        end
      end

      context 'when preferences group not exist' do
        it 'returns nil' do
          expect(model_with_empty_preferences.displayable_preferences(:wrong_group)).to be_nil
        end
      end

    end

  end

end