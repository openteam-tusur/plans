class AddPracticeControlToSelfEducations < ActiveRecord::Migration
  def change
    add_column :self_educations, :practice_hours, :integer
    add_column :self_educations, :practice_control, :text
  end
end
