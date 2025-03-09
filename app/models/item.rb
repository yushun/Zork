class Item < ApplicationRecord
  belongs_to :room, optional: true
  belongs_to :player, optional: true
  belongs_to :container, class_name: 'Item', optional: true
  has_many :contained_items, class_name: 'Item', foreign_key: 'container_id'
  
  validates :name, presence: true
  validates :weight, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :description, presence: true
  validates :armor_rating, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :damage, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
  # Add enum for item type/category
  enum :item_type, {
    weapon: 0,
    tool: 1,
    key: 2,
    container: 3,
    readable: 4,
    armor: 5,
    consumable: 6
  }
  
  # Default values for new items
  after_initialize :set_defaults, unless: :persisted?
  
  # Scopes for easy querying
  scope :equippable, -> { where(item_type: [:weapon, :armor]) }
  scope :carriable, -> { where(is_carriable: true) }
  scope :equipped, -> { where(is_equipped: true) }
  scope :in_container, ->(container_id) { where(container_id: container_id) }
  scope :in_room, ->(room_id) { where(room_id: room_id) }
  
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
  def drop(room)
    return false unless room
    update(player: nil, is_equipped: false, room: room)
  end

  # Toggle equipped status
  def toggle_equipped
    return false unless equippable?
    
    update(is_equipped: !is_equipped)
  end

  # Get combat stats
  def combat_stats
    if weapon?
      { damage: damage || 0 }
    elsif armor?
      { armor_rating: armor_rating || 0 }
    else
      {}
    end
  end

  # Check if item can contain other items
  def can_contain_items?
    container?
  end

  # Add item to container
  def add_to_container(container_item)
    return false unless container_item&.can_contain_items?
    update(container: container_item)
  end

  # Remove item from container
  def remove_from_container
    update(container: nil)
  end

  # Get total weight (including contained items)
  def total_weight
    base_weight = weight || 0
    if can_contain_items?
      base_weight + contained_items.sum(&:total_weight)
    else
      base_weight
    end
  end

  private

  def set_defaults
    self.weight ||= 0.1
    self.is_carriable ||= true
    self.is_equipped ||= false
    self.armor_rating ||= 0 if armor?
    self.damage ||= 0 if weapon?
  end
end 