class CreateExaminationQuestions < ActiveRecord::Migration
  def change
    create_table :examination_questions do |t|
      t.references :work_programm
      t.references :semester
      t.string :question_kind
      t.integer :score

      t.timestamps
    end
    add_index :examination_questions, :work_programm_id
    add_index :examination_questions, :semester_id
  end
end
