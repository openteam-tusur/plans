class CreateCompetencesDisciplinesTable < ActiveRecord::Migration
  def change
    create_table :competences_disciplines, :id => false do |t|
      t.references :competence
      t.references :discipline
    end

    add_index :competences_disciplines, :competence_id
    add_index :competences_disciplines, :discipline_id
  end
end
