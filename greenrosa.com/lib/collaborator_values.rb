require 'active_support'    # for symbolize_keys
require 'yaml'

module CollaboratorValues
  #CollaboratorValues::CollaboratorMethods.collaborator_value
  class CollaboratorMethods 
    class << self
      attr_accessor :collaborator_value, :us_states, :collaborator, :countries, :display_rows, :application_status


      def load_values
        @collaborator = Hash.new
        file = File.open("#{Rails.application.root}/collaborator/collaborator_values.yml")
        @collaborator_value = YAML::load(file)
      end

      
    end
  end
end

