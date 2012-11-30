# == Schema Information
#
# Table name: publications
#
#  id               :integer          not null, primary key
#  work_programm_id :integer
#  publication_kind :string(255)
#  text             :text
#  url              :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  location         :string(255)
#  count            :integer
#

Fabricator(:publication) do
  work_programm nil
  kind "MyString"
  place "MyString"
  text "MyText"
  url "MyText"
end
