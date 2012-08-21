class Context < ActiveRecord::Base
  attr_accessible :title
  has_many :subdepartments
  esp_auth_context :subcontext => false
end

# == Schema Information
#
# Table name: contexts
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  ancestry   :string(255)
#  weight     :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

