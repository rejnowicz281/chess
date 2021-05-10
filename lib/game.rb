# frozen_string_literal: true

require_relative 'board'
require_relative 'innitial_placement'
require_relative 'castling'
require_relative 'en_passant'
Dir['pieces/*.rb'].each { |piece| require_relative piece }

# game class
class Game
  include InnitialPlacement
  include PawnBehaviour
  include Castling
  include EnPassant

  attr_reader :board
  attr_accessor :save_popup

  def initialize
    Dir.mkdir('saves') unless Dir.exist?('saves')
    @save_popup = true
    @board = Board.new
    place_pieces
  end

  def human_round
    loop do
      play_turn('white')
      if checkmated?('white')
        puts 'Black wins'
        return
      elsif checkmated?('black')
        puts 'White wins'
        return
      end

      play_turn('black')
      if checkmated?('white')
        puts 'Black wins'
        return
      elsif checkmated?('black')
        puts 'White wins'
        return
      end
    end
  end

  def computer_round
    loop do
      play_turn('white')
      if checkmated?('white')
        puts 'Black wins'
        return
      elsif checkmated?('black')
        puts 'White wins'
        return
      end

      computer_turn('black')
      if checkmated?('white')
        puts 'Black wins'
        return
      elsif checkmated?('black')
        puts 'White wins'
        return
      end
    end
  end

  def play_round
    game_type = choose_game_type
    if game_type == 'human'
      human_round
    else
      computer_round
    end
  end

  def choose_game_type
    print 'Type in 1 if you want to play against a human. Type 2 if you want to play against a computer: '
    choice = gets.chomp
    case choice
    when '1'
      'human'
    when '2'
      'computer'
    end
  end

  def computer_turn(player_color)
    en_passant_counters_increase(player_color)

    king_of(player_color).in_check_counter += 1 if king_in_check?(player_color)
    puts "Current player: #{player_color}."

    moving_piece = viable_pieces_to_move(player_color).sample
    print "\nI'm moving #{moving_piece} ---> "

    destination = legal_moves_of(moving_piece).sample
    print "#{destination}\n\n"

    if en_passant_moves(moving_piece).include?(destination)
      en_passant_move(moving_piece, destination)
    elsif castling_moves(moving_piece).include?(destination)
      castling_move(moving_piece, destination)
    else
      move(moving_piece, destination)
    end

    promote(destination, 'queen') if promotion?(destination)

    king_of(player_color).in_check_counter += 1 if king_in_check?(player_color)
    king_of(player_color).in_check_counter = 0 if king_of(player_color).in_check_counter == 1 && !king_in_check?(player_color)
  end

  def play
    if no_saved_games?
      play_round
    else
      load_prompt
    end
  end

  def play_turn(player_color)
    en_passant_counters_increase(player_color)
    board.display

    king_of(player_color).in_check_counter += 1 if king_in_check?(player_color)
    puts "Current player: #{player_color}."

    p king_in_check?(player_color) ? 'You are in check. Defend your king!' : 'You are NOT in check.'

    save_prompt if save_popup

    moving_piece = input_moving_piece(player_color)

    puts "Legal moves: #{legal_moves_of(moving_piece)}"
    castling_moves(moving_piece).each { |castling_move| puts "#{castling_move} is a castling move" }

    destination = input_destination(moving_piece)

    if en_passant_moves(moving_piece).include?(destination)
      en_passant_move(moving_piece, destination)
    elsif castling_moves(moving_piece).include?(destination)
      castling_move(moving_piece, destination)
    else
      move(moving_piece, destination)
    end

    promotion_prompt(destination) if promotion?(destination)

    king_of(player_color).in_check_counter += 1 if king_in_check?(player_color)
    king_of(player_color).in_check_counter = 0 if king_of(player_color).in_check_counter == 1 && !king_in_check?(player_color)
  end

  def enable_save_popup?
    print 'Type 1 if you would like to enable save popup: '
    choice = gets.chomp
    self.save_popup = true if choice == '1'
  end

  def load_prompt
    print 'Type 1 if you would like to load a save: '
    choice = gets.chomp
    case choice
    when '1'
      puts 'Available saves: '
      saves_array = Dir.children('saves')
      saves_array.each { |save| puts save }
      loop do
        print 'Type in index of a save to load it: '
        save_index = gets.chomp
        save_index = save_index.to_i
        next unless save_index < saves_array.length

        load_save(save_index)
      end
    else
      play_round
    end
  end

  def load_save(save_index)
    save = File.read("saves/save#{save_index}.marshal")
    new_game = Marshal::load(save)
    puts 'Game loaded.'
    new_game.play_round
  end

  def save_prompt
    print 'Would you like to save the game?(1-yes, 2-dont ask): '
    choice = gets.chomp
    case choice
    when '1'
      save_game
    when '2'
      self.save_popup = false
    end
  end

  def no_saved_games?
    Dir.children('saves').empty?
  end

  def save_game
    saves_array = Dir.children('saves')
    save = File.new("saves/save#{saves_array.length}.marshal", 'w')
    save.write "#{Marshal::dump(self)}"
    save.close
  end

  def input_moving_piece(player_color)
    loop do
      puts 'Type in cords of the piece you want to move: '
      moving_piece = gets.chomp
      return moving_piece if viable_pieces_to_move(player_color).include?(moving_piece)
    end
  end

  def viable_pieces_to_move(player_color)
    player_piece_cords = squares_of(player_color).map(&:cords)
    player_piece_cords.reject { |piece_cords| legal_moves_of(piece_cords).empty? }
  end

  def input_destination(moving_piece)
    loop do
      puts 'Type in where you want to move the piece: '
      destination = gets.chomp
      return destination if legal_moves_of(moving_piece).include?(destination)
    end
  end

  def same_color?(square1_cords, square2_cords)
    square1 = board.get_square(square1_cords)
    square2 = board.get_square(square2_cords)

    !square2.empty? && square2.piece.color == square1.piece.color
  end

  def move(start, destination)
    start_square = board.get_square(start)
    destination_square = board.get_square(destination)

    destination_square.piece = start_square.piece
    destination_square.piece.previous_move = start
    delete_piece_from(start)
  end

  def path_clear?(start, destination)
    return true if board.get_square(start).piece.is_a? Knight

    path = board.path(start, destination)

    path.each { |square| return false if !square.empty? && square.cords != destination }

    true
  end

  def invalid_path?(start, destination)
    return true if board.invalid_cords?(start) || board.invalid_cords?(destination)

    start_square = board.get_square(start)

    start_square.movement.nil? || !start_square.movement.include?(destination) || !path_clear?(start, destination)
  end

  def legal_moves_of(cords)
    square = board.get_square(cords)

    legal_moves = []

    square.movement.each { |move| legal_moves << move unless illegal_move?(cords, move) }

    legal_moves -= illegal_pawn_moves(cords) if square.piece.is_a? Pawn
    legal_moves += en_passant_moves(cords)
    legal_moves += castling_moves(cords)

    legal_moves
  end

  def illegal_move?(start, destination)
    invalid_path?(start, destination) || same_color?(start, destination)
  end

  def made_double_step_move?(cords)
    square = board.get_square(cords)
    return false unless square.piece.is_a? Pawn

    previous_move = square.piece.previous_move
    two_downwards = downwards_from(cords, 2)

    previous_move == two_downwards
  end

  def left_of(cords, i = 1)
    "#{(cords[0].ord - i).chr}#{cords[1]}"
  end

  def right_of(cords, i = 1)
    "#{(cords[0].ord + i).chr}#{cords[1]}"
  end

  def downwards_from(cords, i = 1)
    color = board.get_square(cords).piece.color
    "#{cords[0]}#{cords[1].to_i + (color == 'black' ? i : -i)}"
  end

  def forwards_from(cords, i = 1)
    color = board.get_square(cords).piece.color
    "#{cords[0]}#{cords[1].to_i + (color == 'black' ? -i : i)}"
  end

  def squares_of(player_color)
    player_squares = []
    board.squares.each do |square|
      player_squares << square if !square.empty? && square.piece.color == player_color
    end
    player_squares
  end

  def king_square_of(player_color)
    squares_of(player_color).each { |square| return square if square.piece.is_a? King }
  end

  def king_cords_of(player_color)
    squares_of(player_color).each { |square| return square.cords if square.piece.is_a? King }
  end

  def king_of(player_color)
    squares_of(player_color).each { |square| return square.piece if square.piece.is_a? King }
  end

  def can_be_captured?(piece_cords)
    player_square = board.get_square(piece_cords)
    return false if player_square.empty?

    player_color = player_square.piece.color
    enemy_color = player_color == 'black' ? 'white' : 'black'
    enemy_squares = squares_of(enemy_color)

    enemy_squares.each do |enemy_square|
      enemy_legal_moves = legal_moves_of(enemy_square.cords)
      return true if enemy_legal_moves.include?(piece_cords)
    end
    false
  end

  def king_in_check?(player_color)
    can_be_captured?(king_cords_of(player_color))
  end

  def checkmated?(player_color)
    king_of(player_color).in_check_counter == 2
  end

  def place(cords, piece)
    board.get_square(cords).piece = piece
  end

  def delete_piece_from(square_cords)
    board.get_square(square_cords).piece = ' '
  end

  def promotion?(pawn_cords)
    return false unless board.get_square(pawn_cords).piece.is_a? Pawn

    pawn_rank = board.get_square(pawn_cords).rank_cord
    pawn_color = board.get_square(pawn_cords).piece.color

    pawn_rank == if pawn_color == 'black'
                   1
                 else
                   8
                 end
  end

  def promotion_prompt(pawn_cords)
    loop do
      puts 'Your pawn must promote. Type in a piece of your choice to promote to it: '
      promotion_pieces = %w[queen rook bishop knight]
      promotion_piece = gets.chomp
      return promote(pawn_cords, promotion_piece) if promotion_pieces.include?(promotion_piece)
    end
  end

  def promote(pawn_cords, promotion_piece)
    pawn_color = board.get_square(pawn_cords).piece.color
    board.get_square(pawn_cords).piece = case promotion_piece
                                         when 'queen'
                                           Queen.new(pawn_color)
                                         when 'rook'
                                           Rook.new(pawn_color)
                                         when 'bishop'
                                           Bishop.new(pawn_color)
                                         when 'knight'
                                           Knight.new(pawn_color)
                                         end
    puts "Promotion to #{promotion_piece}."
  end
end

g = Game.new

g.play
