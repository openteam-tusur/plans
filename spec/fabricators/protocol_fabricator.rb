# == Schema Information
#
# Table name: protocols
#
#  id               :integer          not null, primary key
#  work_programm_id :integer
#  number           :string(255)
#  signed_on        :date
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

Fabricator(:protocol) do
  work_programm nil
  number        "MyString"
  signed_on     "2012-08-22"
end
