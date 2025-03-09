class Player < ApplicationRecord
  belongs_to :current_room, class_name: 'Room'
  has_many :items
  has_many :inventory, class_name: 'Item'
  
  def move(direction)
    exit = current_room.exits.find_by(direction: direction)
    if exit
      update(current_room: exit.destination)
      "You moved #{direction} to #{current_room.name}"
    else
      "You can't go that way."
    end
  end

  def take(item_name)
    item = current_room.items.find_by(name: item_name)
    if item
      item.update(room: nil, player: self)
      "You took the #{item.name}"
    else
      "You don't see that here."
    end
  end

  def drop(item_name)
    item = inventory.find_by(name: item_name)
    if item
      item.update(room: current_room, player: nil)
      "You dropped the #{item.name}"
    else
      "You don't have that."
    end
  end

  def look
    desc = "#{current_room.description}\n\n"
    desc += "Exits: #{current_room.exits.pluck(:direction).join(', ')}\n\n"
    
    items = current_room.items.pluck(:name)
    desc += "You see: #{items.join(', ')}" if items.any?
    desc
  end
end 