class Item < ApplicationRecord
  belongs_to :room
  belongs_to :player, optional: true
  
  validates :name, presence: true
  validates :weight, numericality: { greater_than_or_equal_to: 0 }
  
  # Add enum for item type/category
  enum item_type: {
    weapon: 0,
    armor: 1,
    consumable: 2,
    quest_item: 3,
    treasure: 4
  }
  
  # Scopes for easy querying
  scope :equippable, -> { where(item_type: [:weapon, :armor]) }
  scope :carriable, -> { where(is_carriable: true) }

  # Check if item can be picked up
  def can_pickup?
    is_carriable && player.nil?
  end

  # Check if item is currently equipped
  def equipped?
    is_equipped
  end

  # Check if item can be equipped (weapons and armor)
  def equippable?
    weapon? || armor?
  end

  # Transfer item to a player
  def give_to(new_player)
    return false unless can_pickup?
    
    update(player: new_player)
  end

  # Drop item in current room
  def drop
    update(player: nil, is_equipped: false)
  end

  # Toggle equipped status
  def toggle_equipped
    return false unless equippable?
    
    update(is_equipped: !is_equipped)
  end
end 