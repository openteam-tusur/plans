class Permission < ActiveRecord::Base
  attr_accessible :context, :role, :user_id, :context_id, :context_type

  sso_auth_permission :roles => %w[manager methodologist]

  extend Enumerize
  enumerize :role, :in => %w[manager methodologist]
end

# == Schema Information
#
# Table name: permissions
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  context_id   :integer
#  context_type :string(255)
#  role         :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

