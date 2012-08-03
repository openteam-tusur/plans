class AddWeightToSelfEducationItems < ActiveRecord::Migration
  def change
    add_column :self_education_items, :weight, :integer
  end
end
