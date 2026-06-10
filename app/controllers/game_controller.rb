class GameController < ApplicationController
  before_action :set_player
  
  def index
    transcript = transcript_entries
    transcript << system_entry(@player.look) if transcript.empty?
    persist_transcript(transcript)
    @transcript = transcript
  end

  def command
    command_text = params[:command].to_s.strip
    words = command_text.downcase.split
    verb = words.first
    rest = words.drop(1)
    previous_room_id = @player.current_room_id

    output = case verb
             when 'go' then @player.move(rest)
             when 'n', 's', 'e', 'w', 'u', 'd' then @player.move(verb)
             when 'enter' then @player.enter(rest)
             when 'exit' then @player.exit_area(rest)
             when 'where' then @player.whereami
             when 'back' then move_back
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

        track_previous_room(previous_room_id)

    transcript = transcript_entries
    transcript << command_entry(command_text) if command_text.present?
    transcript << system_entry(output)
    persist_transcript(transcript)
    @transcript = transcript
    
    render :index
  end

  private
  
  def set_player
    session.delete(:transcript)
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
      - n, s, e, w, u, d
      - enter [direction]
      - exit [direction]
      - where
      - back
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
    @player.transcript_entries
  end

  def persist_transcript(entries)
    @player.replace_transcript(entries)
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

  def track_previous_room(previous_room_id)
    return if previous_room_id.blank?
    return if @player.current_room_id == previous_room_id

    session[:previous_room_id] = previous_room_id
  end

  def move_back
    previous_room_id = session[:previous_room_id]
    return "You have nowhere to go back to." if previous_room_id.blank?

    destination = Room.find_by(id: previous_room_id)
    return "You have nowhere to go back to." unless destination

    current_room_id = @player.current_room_id
    @player.update!(current_room: destination)
    session[:previous_room_id] = current_room_id
    "You go back to #{destination.name}."
  end
end 