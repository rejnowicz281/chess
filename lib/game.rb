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

    square1 != ' ' && !square2.empty? && square2.piece.color == square1.piece.color
  end

  def move(start, destination)
    start_square = board.get_square(start)
    destination_square = board.get_square(destination)

    destination_square.piece = start_square.piece
    destination_square.piece.previous_move = start_square.cords
    start_square.piece = ' '
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
      legal_moves = remove_illegal_pawn_moves(cords, legal_moves)
    end

    legal_moves
  end

  def illegal_move?(start, destination)
    invalid_path?(start, destination) || same_color?(start, destination)
  end

  def made_double_step_move?(square_cords)
    square = board.get_square(square_cords)
    return false unless square.piece.is_a? Pawn

    previous_move = square.piece.previous_move
    backwards = bottom_of(square_cords)
    two_backwards = bottom_of(backwards)

    previous_move == two_backwards
  end

  def left_of(square_cords)
    "#{(square_cords[0].ord - 1).chr}#{square_cords[1]}"
  end

  def right_of(square_cords)
    "#{(square_cords[0].ord + 1).chr}#{square_cords[1]}"
  end

  def backwards_from(square_cords)
    square = board.get_square(square_cords)
    "#{square_cords[0]}#{square_cords[1].to_i + (square.piece.color == 'black' ? 1 : -1)}"
  end

  def forwards_from(square_cords)
    square = board.get_square(square_cords)
    "#{square_cords[0]}#{square_cords[1].to_i + (square.piece.color == 'black' ? -1 : 1)}"
  end
end
