class GameController < ApplicationController
  before_action :set_player
  
  def index
    transcript_entries << system_entry(@player.look) if transcript_entries.empty?
    @transcript = transcript_entries
  end

  def command
    command_text = params[:command].to_s.strip
    words = command_text.downcase.split
    verb = words.first
    rest = words.drop(1)

    output = case verb
             when 'go' then @player.move(rest)
             when 'take' then @player.take(rest)
             when 'drop' then @player.drop(rest)
             when 'look' then @player.look
             when 'inventory' then inventory_output
             when 'examine' then @player.examine(rest)
             when 'use' then @player.use(rest)
             when 'talk'
               if rest.first == 'to'
                 @player.talk_to(rest.drop(1))
               else
                 "I don't understand that command."
               end
             when 'help' then show_help
             when 'quit' then "Please refresh the page to start over."
             else "I don't understand that command."
             end

    append_transcript(command_entry(command_text)) if command_text.present?
    append_transcript(system_entry(output))
    @transcript = transcript_entries
    
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

  def transcript_entries
    session[:transcript] ||= []
  end

  def append_transcript(entry)
    transcript_entries << entry
    session[:transcript] = transcript_entries.last(40)
  end

  def system_entry(text)
    { "kind" => "system", "text" => text.to_s }
  end

  def command_entry(text)
    { "kind" => "command", "text" => text.to_s }
  end

  def inventory_output
    items = @player.inventory.pluck(:name)
    return "You are carrying nothing." if items.empty?

    "You are carrying: #{items.join(', ')}"
  end
end 