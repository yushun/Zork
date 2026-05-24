class Player < ApplicationRecord
  belongs_to :current_room, class_name: 'Room'
  has_many :items
  has_many :inventory, class_name: 'Item'
  serialize :transcript, coder: JSON

  def transcript_entries
    Array(transcript)
  end

  def replace_transcript(entries)
    update!(transcript: entries.last(40))
  end
  
  def move(direction)
    direction_name = normalize_terms(direction)
    return "Go where?" if direction_name.blank?

    exit = current_room.exits.find_by(direction: direction_name)
    if exit
      update(current_room: exit.destination)
      "You moved #{direction_name} to #{current_room.name}"
    else
      "You can't go that way."
    end
  end

  def take(item_name)
    item_name = normalize_terms(item_name)
    return "Take what?" if item_name.blank?

    item = find_visible_room_item(item_name)
    if item
      return "You can't take the #{item.name}." unless item.can_pickup?

      item.update(room: nil, player: self, container: nil)
      "You took the #{item.name}"
    else
      "You don't see that here."
    end
  end

  def drop(item_name)
    item_name = normalize_terms(item_name)
    return "Drop what?" if item_name.blank?

    item = inventory.find_by(name: item_name)
    if item
      item.update(room: current_room, player: nil)
      "You dropped the #{item.name}"
    else
      "You don't have that."
    end
  end

  def examine(item_name)
    item_name = normalize_terms(item_name)
    return "Examine what?" if item_name.blank?

    item = find_accessible_item(item_name)
    return "You don't see that here." unless item

    details = [item.description]

    if item.can_contain_items?
      contents = item.contained_items.pluck(:name)
      details << if contents.any?
                   "It contains: #{contents.join(', ')}."
                 else
                   "It is empty."
                 end
    end

    if item.equippable?
      stats = item.combat_stats.map { |key, value| "#{key.to_s.humanize}: #{value}" }
      details << stats.join(', ') if stats.any?
      details << (item.equipped? ? "It is currently equipped." : "It can be equipped.")
    end

    details.join("\n")
  end

  def use(item_name)
    item_name = normalize_terms(item_name)
    return "Use what?" if item_name.blank?

    item = find_accessible_item(item_name)
    return "You don't have that." unless item

    if item.readable?
      item.description
    elsif item.equippable?
      item.toggle_equipped
      item.reload
      item.equipped? ? "You equip the #{item.name}." : "You unequip the #{item.name}."
    elsif item.consumable?
      item.destroy
      "You use the #{item_name}."
    elsif item.can_contain_items?
      contents = item.contained_items.pluck(:name)
      if contents.any?
        "You open the #{item.name}. It contains: #{contents.join(', ')}."
      else
        "You open the #{item.name}, but it is empty."
      end
    else
      "You use the #{item.name}, but nothing obvious happens."
    end
  end

  def talk_to(npc_name)
    npc_name = normalize_terms(npc_name)
    return "Talk to whom?" if npc_name.blank?

    "There is no #{npc_name} here to talk to."
  end

  def look
    desc = "#{current_room.description}\n\n"
    desc += "Exits: #{current_room.exits.pluck(:direction).join(', ')}\n\n"
    
    items = current_room.items.pluck(:name)
    desc += "You see: #{items.join(', ')}" if items.any?
    desc
  end

  private

  def normalize_terms(terms)
    Array(terms).join(' ').squish
  end

  def find_accessible_item(item_name)
    inventory.find_by(name: item_name) || find_visible_room_item(item_name)
  end

  def find_visible_room_item(item_name)
    visible_room_items.find { |item| item.name == item_name }
  end

  def visible_room_items
    root_items = current_room.items.includes(:contained_items).to_a
    nested_items = root_items.flat_map(&:contained_items)
    root_items + nested_items
  end
end 