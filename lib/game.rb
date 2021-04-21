# frozen_string_literal: true

require_relative 'board'
require_relative 'innitial_placement'
Dir['pieces/*.rb'].each { |piece| require_relative piece }

# game class
class Game
  include InnitialPlacement
  include PawnBehaviour
  attr_reader :board

  def initialize
    @board = Board.new
    place_pieces
  end

  def play
    loop do
      play_turn('white')
      play_turn('black')
    end
  end

  def play_turn(curr_player_color)
    puts "Current player: #{curr_player_color}."
    moving_piece = input_moving_piece(curr_player_color)
    puts "Legal moves: #{legal_moves_of(moving_piece)}"

    destination = choose_destination(moving_piece)

    move(moving_piece, destination)
  end

  def input_moving_piece(curr_player_color)
    loop do
      board.display
      puts 'Type in cords of the piece you want to move: '
      moving_piece = gets.chomp
      return moving_piece unless invalid_moving_piece?(moving_piece, curr_player_color)
    end
  end

  def invalid_moving_piece?(moving_piece, curr_player_color)
    return true if board.invalid_cords?(moving_piece)

    moving_piece_square = board.get_square(moving_piece)

    moving_piece_square.empty? || moving_piece_square.piece.color != curr_player_color || legal_moves_of(moving_piece).empty?
  end

  def choose_destination(moving_piece)
    loop do
      board.display
      puts 'Type in where you want to move the piece: '
      destination = gets.chomp
      return destination unless invalid_destination_cords?(moving_piece, destination)
    end
  end

  def invalid_destination_cords?(moving_piece, destination)
    return true if board.invalid_cords?(destination)

    moving_piece_color = board.get_square(moving_piece).piece.color
    destination_square = board.get_square(destination)

    !destination_square.empty? && destination_square.piece.color == moving_piece_color ||
      moving_piece == destination || !legal_moves_of(moving_piece).include?(destination)
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
    destination_square.piece.previous_move = start_square.cords
    start_square.piece = ' '
    if made_en_passant_move?(destination)
      downwards = board.get_square(downwards_from(destination))
      downwards.piece = ' '
    end
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

    if square.piece.is_a? Pawn
      legal_moves -= illegal_pawn_moves(cords)
      legal_moves += en_passant_moves(cords)
    end

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

  def left_of(cords)
    "#{(cords[0].ord - 1).chr}#{cords[1]}"
  end

  def right_of(cords)
    "#{(cords[0].ord + 1).chr}#{cords[1]}"
  end

  def downwards_from(cords, i = 1)
    color = board.get_square(cords).piece.color
    "#{cords[0]}#{cords[1].to_i + (color == 'black' ? i : -i)}"
  end

  def forwards_from(cords, i = 1)
    color = board.get_square(cords).piece.color
    "#{cords[0]}#{cords[1].to_i + (color == 'black' ? -i : i)}"
  end

  def enemy_on_left_of?(cords)
    square = board.get_square(cords)
    left = board.get_square(left_of(cords))

    return false if board.invalid_cords?(left_of(cords)) || left.empty?

    square_color = square.piece.color
    left_color = left.piece.color

    square_color != left_color
  end

  def enemy_on_right_of?(cords)
    square = board.get_square(cords)
    right = board.get_square(right_of(cords))

    return false if board.invalid_cords?(right_of(cords)) || right.empty?

    square_color = square.piece.color
    right_color = right.piece.color

    square_color != right_color
  end

  def en_passant_moves(cords)
    en_passant_moves = []
    if enemy_on_left_of?(cords) && made_double_step_move?(left_of(cords))
      en_passant_move = downwards_from(left_of(cords))
      en_passant_moves << en_passant_move
    elsif enemy_on_right_of?(cords) && made_double_step_move?(right_of(cords))
      en_passant_move = downwards_from(right_of(cords))
      en_passant_moves << en_passant_move
    end
    en_passant_moves
  end

  def made_en_passant_move?(current_pos)
    return false if board.get_square(current_pos).empty?

    previous_move = board.get_square(current_pos).piece.previous_move
    downwards = downwards_from(current_pos)
    forwards = forwards_from(current_pos)

    en_passant_movement = [left_of(downwards), right_of(downwards), left_of(forwards), right_of(forwards)]

    en_passant_movement.include?(previous_move)
  end
end
