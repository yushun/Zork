class Exit < ApplicationRecord
  belongs_to :room
  belongs_to :destination, class_name: 'Room'
  
  validates :direction, presence: true
  
  VALID_DIRECTIONS = %w[north south east west up down].freeze
  
  def opposite_direction
    case direction.downcase
    when 'north' then 'south'
    when 'south' then 'north'
    when 'east'  then 'west'
    when 'west'  then 'east'
    when 'up'    then 'down'
    when 'down'  then 'up'
    else nil
    end
  end
  
  def valid_direction?
    VALID_DIRECTIONS.include?(direction.downcase)
  end
  
  def to_s
    "Exit to #{destination.name} (#{direction})"
  end
end 