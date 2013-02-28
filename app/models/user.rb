class User < ActiveRecord::Base
  attr_accessible :id, :uid, :name, :email, :nickname, :first_name, :last_name, :location, :description, :image
  attr_accessible :phone, :urls, :raw_info

  sso_auth_user

  # TODO show only permitted disciplines for non managers
  def disciplines
    Discipline.scoped
  end
end

# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  uid                :string(255)
#  name               :text
#  email              :text
#  nickname           :text
#  first_name         :text
#  last_name          :text
#  location           :text
#  description        :text
#  image              :text
#  phone              :text
#  urls               :text
#  raw_info           :text
#  sign_in_count      :integer
#  current_sign_in_at :datetime
#  last_sign_in_at    :datetime
#  current_sign_in_ip :string(255)
#  last_sign_in_ip    :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

