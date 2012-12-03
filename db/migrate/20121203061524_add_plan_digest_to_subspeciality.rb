class AddPlanDigestToSubspeciality < ActiveRecord::Migration
  def change
    add_column :subspecialities, :plan_digest, :string
  end
end
