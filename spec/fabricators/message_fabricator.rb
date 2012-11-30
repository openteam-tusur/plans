# == Schema Information
#
# Table name: messages
#
#  id                  :integer          not null, primary key
#  text                :text
#  readed              :boolean
#  work_programm_id    :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  work_programm_state :string(255)
#

Fabricator(:message) do
  text          "MyText"
  readed        false
  folder        "MyString"
  work_programm nil
end
