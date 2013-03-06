# == Schema Information
#
# Table name: people
#
#  id               :integer          not null, primary key
#  academic_degree  :text
#  academic_rank    :text
#  post             :text
#  full_name        :text
#  work_programm_id :integer
#  kind      :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

Fabricator(:person) do
  academic_degree "MyText"
  academic_rank   "MyText"
  post            "MyText"
  full_name       "MyText"
  work_programm   nil
  kind     "MyString"
end
