class AddContainerIdToItems < ActiveRecord::Migration[8.0]
  def change
    add_reference :items, :container, null: true, foreign_key: { to_table: :items }
  end
end
