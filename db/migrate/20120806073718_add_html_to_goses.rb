class AddHtmlToGoses < ActiveRecord::Migration
  def change
    add_column :goses, :html, :text
  end
end
