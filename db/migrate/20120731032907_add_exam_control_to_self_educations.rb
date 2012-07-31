class AddExamControlToSelfEducations < ActiveRecord::Migration
  def change
    add_column :self_educations, :exam_hours, :integer
    add_column :self_educations, :exam_control, :text
  end
end
