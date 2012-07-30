class AddLabControlToSelfEducations < ActiveRecord::Migration
  def change
    add_column :self_educations, :lab_hours, :integer
    add_column :self_educations, :lab_control, :text
  end
end
