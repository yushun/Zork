class GameController < ApplicationController
  before_action :set_player
  
  def index
    @output = @player.look
  end

  def command
    @output = case params[:command].downcase.split
              when ['go', *direction] then @player.move(direction)
              when ['take', *item] then @player.take(item)
              when ['drop', *item] then @player.drop(item)
              when ['look'] then @player.look
              when ['inventory'] then "You are carrying: #{@player.inventory.pluck(:name).join(', ')}"
              when ['examine', *item] then @player.examine(item)
              when ['use', *item] then @player.use(item)
              when ['talk', 'to', *npc] then @player.talk_to(npc)
              when ['help'] then show_help
              when ['quit'] then "Please refresh the page to start over."
              else "I don't understand that command."
              end
    
    render :index
  end

  private
  
  def set_player
    @player = Player.first_or_create!(current_room: starting_room)
  end

  def starting_room
    Room.find_or_create_by!(
      name: 'West of House',
      description: 'You are standing in an open field west of a white house, with a boarded front door.'
    )
  end

  def show_help
    <<~HELP
      Available commands:
      - go [direction]
      - take [item]
      - drop [item]
      - look
      - inventory
      - examine [item]
      - use [item]
      - talk to [person]
      - help
      - quit
    HELP
  end
end 