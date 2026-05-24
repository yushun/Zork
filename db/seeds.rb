# Clear existing data
puts "Clearing existing data..."
Player.delete_all
Exit.delete_all
Item.update_all(container_id: nil)
Item.delete_all
Room.delete_all

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

river_bank = Room.create!(
  name: "River Bank",
  description: "A fast-moving river blocks easy passage. Smooth stones line the muddy bank."
)

cave_entrance = Room.create!(
  name: "Cave Entrance",
  description: "A jagged opening leads into darkness. Cold air rolls out of the cave mouth."
)

damp_cavern = Room.create!(
  name: "Damp Cavern",
  description: "Water drips steadily from the ceiling. The floor is slick and uneven."
)

underground_lake = Room.create!(
  name: "Underground Lake",
  description: "A black, still lake fills this chamber. Ripples spread when you breathe too loudly."
)

attic = Room.create!(
  name: "Attic",
  description: "Dusty beams and cobwebs fill the cramped attic above the house."
)

cellar = Room.create!(
  name: "Cellar",
  description: "The cellar smells of damp wood and old earth. Broken crates are stacked in the corners."
)

# Set up room connections
puts "Setting up room connections..."
rooms = {
  west_of_house: west_of_house,
  north_of_house: north_of_house,
  south_of_house: south_of_house,
  east_of_house: east_of_house,
  forest: forest,
  forest_path: forest_path,
  clearing: clearing,
  river_bank: river_bank,
  cave_entrance: cave_entrance,
  damp_cavern: damp_cavern,
  underground_lake: underground_lake,
  attic: attic,
  cellar: cellar
}

{
  west_of_house: { north: north_of_house, south: south_of_house, east: east_of_house },
  north_of_house: { west: west_of_house, east: east_of_house },
  south_of_house: { west: west_of_house, east: east_of_house },
  east_of_house: { north: north_of_house, south: south_of_house, east: forest, up: attic, down: cellar },
  attic: { down: east_of_house },
  cellar: { up: east_of_house, east: cave_entrance },
  forest: { west: east_of_house, east: forest_path, north: clearing, south: river_bank },
  forest_path: { west: forest, east: cave_entrance },
  clearing: { south: forest, east: river_bank },
  river_bank: { north: forest, west: clearing, east: cave_entrance },
  cave_entrance: { west: forest_path, east: damp_cavern, up: river_bank },
  damp_cavern: { west: cave_entrance, east: underground_lake },
  underground_lake: { west: damp_cavern }
}.each do |room_name, connections|
  room = rooms.fetch(room_name)
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

wooden_chest = Item.create!(
  name: "wooden chest",
  description: "A heavy chest with iron bands. The hinge squeaks when touched.",
  room: cellar,
  item_type: :container,
  weight: 10.0,
  is_carriable: false
)

wicker_basket = Item.create!(
  name: "wicker basket",
  description: "A handwoven basket, damp but still sturdy.",
  room: river_bank,
  item_type: :container,
  weight: 1.5,
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

journal = Item.create!(
  name: "explorer journal",
  description: "Day 17: The lake below the cave seems deeper than it looks. I heard chains in the dark.",
  item_type: :readable,
  weight: 0.2,
  container: wooden_chest
)

map = Item.create!(
  name: "charcoal map",
  description: "A rough map marks a house, a river, and a cave linked by narrow paths.",
  item_type: :readable,
  weight: 0.1,
  container: wicker_basket
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

pickaxe = Item.create!(
  name: "iron pickaxe",
  description: "A miner's pickaxe, chipped at the edge but still deadly in close quarters.",
  room: cave_entrance,
  item_type: :weapon,
  weight: 5.0,
  damage: 8
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

grappling_hook = Item.create!(
  name: "grappling hook",
  description: "A three-pronged hook tied to a frayed loop.",
  room: attic,
  item_type: :tool,
  weight: 2.5
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

silver_key = Item.create!(
  name: "silver key",
  description: "A tarnished silver key with a fish-shaped bow.",
  item_type: :key,
  weight: 0.1,
  container: wooden_chest
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

dried_meat = Item.create!(
  name: "dried meat",
  description: "A strip of heavily salted meat. Not delicious, but it will keep you going.",
  item_type: :consumable,
  weight: 0.3,
  container: wicker_basket
)

glowing_mushroom = Item.create!(
  name: "glowing mushroom",
  description: "A pale fungus that emits a faint blue light.",
  room: damp_cavern,
  item_type: :consumable,
  weight: 0.1
)

# Create initial player
puts "Creating player..."
Player.create!(
  current_room: west_of_house
)

puts "Seed completed successfully!" 