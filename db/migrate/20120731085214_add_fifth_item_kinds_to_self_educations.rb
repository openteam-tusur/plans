class AddFifthItemKindsToSelfEducations < ActiveRecord::Migration
  def change
    %w[home_work referat test colloquium calculation].each do |kind|
      add_column :self_educations, "#{kind}_hours", :integer
      add_column :self_educations, "#{kind}_control", :text
    end
  end
end
