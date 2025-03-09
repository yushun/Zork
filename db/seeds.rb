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

# Set up room connections
puts "Setting up room connections..."
{
  west_of_house: { north: north_of_house, south: south_of_house, east: east_of_house },
  north_of_house: { west: west_of_house, east: east_of_house },
  south_of_house: { west: west_of_house, east: east_of_house },
  east_of_house: { north: north_of_house, south: south_of_house, east: forest },
  forest: { west: east_of_house, east: forest_path },
  forest_path: { west: forest }
}.each do |room_name, connections|
  room = eval(room_name.to_s)
  connections.each do |direction, connected_room_name|
    connected_room = eval(connected_room_name.to_s)
    room.connected_rooms << connected_room
  end
end

# Create Items
puts "Creating items..."
mailbox = Item.create!(
  name: "mailbox",
  description: "It's a small mailbox.",
  room: west_of_house,
  is_container: true,
  can_be_taken: false
)

leaflet = Item.create!(
  name: "leaflet",
  description: "Welcome to Zork!\nZork is a game of adventure, danger, and low cunning...",
  room: west_of_house,
  container: mailbox
)

sword = Item.create!(
  name: "sword",
  description: "A elvish sword of great antiquity.",
  room: forest_path
)

lantern = Item.create!(
  name: "brass lantern",
  description: "A battery-powered brass lantern",
  room: forest
)

# Create initial player
puts "Creating player..."
Player.create!(
  current_room: west_of_house
)

puts "Seed completed successfully!" 