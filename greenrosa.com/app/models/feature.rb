class Feature < ActiveRecord::Base
 
  belongs_to :alternative
#  validates_presence_of :record_text

 def validate

    if record_text.blank? 
      errors.add(:missing_feature, ":Each collaborative offering requires at least one feature.")
    end

 
  end

 def destroy_feature
    # TODO something later
  end
end
