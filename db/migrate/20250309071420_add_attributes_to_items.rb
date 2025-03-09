class AddAttributesToItems < ActiveRecord::Migration[8.0]
  def change
    add_column :items, :weight, :decimal
    add_column :items, :is_carriable, :boolean
    add_column :items, :is_equipped, :boolean
    add_column :items, :armor_rating, :integer
    add_column :items, :damage, :integer
  end
end
