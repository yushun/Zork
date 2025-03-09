class CreateZorkTables < ActiveRecord::Migration[8.0]
  def change
    create_table :rooms do |t|
      t.string :name
      t.text :description
      t.timestamps
    end

    create_table :exits do |t|
      t.references :room
      t.references :destination
      t.string :direction
      t.timestamps
    end

    create_table :items do |t|
      t.string :name
      t.text :description
      t.integer :item_type
      t.references :room, null: true
      t.references :player, null: true
      t.timestamps
    end

    create_table :players do |t|
      t.references :current_room
      t.timestamps
    end
  end
end 