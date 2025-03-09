class Room < ApplicationRecord
  has_many :exits
  has_many :items
  has_many :connected_rooms, through: :exits
end 