# Clear existing data
puts "Clearing existing data..."
Room.destroy_all
Item.destroy_all
Player.destroy_all

# Create Rooms
puts "Creating rooms..."
west_of_house = Room.create!(
  name: "West of House",
  description: "You are standing in an open field west of a white house, with a boarded front door. There is a small mailbox here."
)

north_of_house = Room.create!(
  name: "North of House",
  description: "You are facing the north side of a white house. There is no door here, and all the windows are barred."
)

south_of_house = Room.create!(
  name: "South of House",
  description: "You are facing the south side of a white house. There is a window here, but it is boarded."
)

east_of_house = Room.create!(
  name: "East of House",
  description: "You are behind the white house. A path leads into the forest to the east. In one corner of the house there is a small window which is slightly ajar."
)

forest = Room.create!(
  name: "Forest",
  description: "This is a forest, with trees in all directions. To the east, there appears to be sunlight."
)

forest_path = Room.create!(
  name: "Forest Path",
  description: "This is a path winding through a dimly lit forest. The path heads north-south here. One particularly large tree with some low branches stands at the edge of the path."
)

clearing = Room.create!(
  name: "Clearing",
  description: "You are in a clearing, with a forest surrounding you on all sides. A path leads south."
)

# Set up room connections
puts "Setting up room connections..."
{
  west_of_house: { north: north_of_house, south: south_of_house, east: east_of_house },
  north_of_house: { west: west_of_house, east: east_of_house },
  south_of_house: { west: west_of_house, east: east_of_house },
  east_of_house: { north: north_of_house, south: south_of_house, east: forest },
  forest: { west: east_of_house, east: forest_path, north: clearing },
  forest_path: { west: forest },
  clearing: { south: forest }
}.each do |room_name, connections|
  room = eval(room_name.to_s)
  connections.each do |direction, connected_room|
    Exit.create!(room: room, destination: connected_room, direction: direction)
  end
end

# Create Items
puts "Creating items..."

# Containers
mailbox = Item.create!(
  name: "mailbox",
  description: "It's a small mailbox.",
  room: west_of_house,
  item_type: :container,
  weight: 2.0,
  is_carriable: false
)

leather_bag = Item.create!(
  name: "leather bag",
  description: "A sturdy leather bag that can hold various items.",
  room: forest_path,
  item_type: :container,
  weight: 0.5,
  is_carriable: true
)

# Readable Items
leaflet = Item.create!(
  name: "leaflet",
  description: "Welcome to Zork!\nZork is a game of adventure, danger, and low cunning...",
  item_type: :readable,
  weight: 0.1,
  container: mailbox
)

ancient_scroll = Item.create!(
  name: "ancient scroll",
  description: "A weathered scroll with mysterious runes.",
  room: clearing,
  item_type: :readable,
  weight: 0.1
)

# Weapons
sword = Item.create!(
  name: "elvish sword",
  description: "A finely crafted sword of elvish design. It glows faintly blue.",
  room: forest_path,
  item_type: :weapon,
  weight: 3.0,
  damage: 10
)

dagger = Item.create!(
  name: "rusty dagger",
  description: "A worn but serviceable dagger.",
  room: forest,
  item_type: :weapon,
  weight: 1.0,
  damage: 5
)

# Armor
shield = Item.create!(
  name: "wooden shield",
  description: "A round wooden shield with metal bindings.",
  room: clearing,
  item_type: :armor,
  weight: 4.0,
  armor_rating: 5
)

leather_armor = Item.create!(
  name: "leather armor",
  description: "A well-made suit of leather armor.",
  container: leather_bag,
  item_type: :armor,
  weight: 8.0,
  armor_rating: 3
)

# Tools
lantern = Item.create!(
  name: "brass lantern",
  description: "A battery-powered brass lantern",
  room: forest,
  item_type: :tool,
  weight: 2.0
)

rope = Item.create!(
  name: "rope",
  description: "A sturdy hemp rope, about 50 feet long.",
  container: leather_bag,
  item_type: :tool,
  weight: 3.0
)

# Keys
brass_key = Item.create!(
  name: "brass key",
  description: "A small brass key with intricate engravings.",
  room: north_of_house,
  item_type: :key,
  weight: 0.1
)

# Consumables
bread = Item.create!(
  name: "fresh bread",
  description: "A loaf of fresh bread, still warm to the touch.",
  container: leather_bag,
  item_type: :consumable,
  weight: 0.5
)

healing_potion = Item.create!(
  name: "healing potion",
  description: "A small vial containing a red liquid.",
  room: clearing,
  item_type: :consumable,
  weight: 0.2
)

# Create initial player
puts "Creating player..."
Player.create!(
  current_room: west_of_house
)

puts "Seed completed successfully!" 