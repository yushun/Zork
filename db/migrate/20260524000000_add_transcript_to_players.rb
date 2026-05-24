class AddTranscriptToPlayers < ActiveRecord::Migration[8.0]
  def change
    add_column :players, :transcript, :text
  end
end