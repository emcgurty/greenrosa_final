class Collaborate < ActiveRecord::Base

  ## Intersection table betweeen user and alternatives
 has_many :user
 has_many :alternatives
end

