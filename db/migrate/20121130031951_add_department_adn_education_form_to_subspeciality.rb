class AddDepartmentAdnEducationFormToSubspeciality < ActiveRecord::Migration
  def change
    add_column :subspecialities, :department_id, :integer
    add_column :subspecialities, :education_form, :string
    Subspeciality.update_all(education_form: 'full-time')
  end
end
