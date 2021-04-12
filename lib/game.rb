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
    piece_to_move = choose_piece_to_move(curr_player_color)
    puts "Legal moves: #{legal_moves_of(piece_to_move)}"

    destination = choose_destination(piece_to_move)

    move(piece_to_move, destination)
  end

  def choose_piece_to_move(curr_player_color)
    loop do
      board.display
      puts 'Type in cords of the piece you want to move: '
      piece_to_move = gets.chomp
      return piece_to_move unless invalid_piece_to_move_cords?(piece_to_move, curr_player_color)
    end
  end

  def invalid_piece_to_move_cords?(piece_to_move, curr_player_color)
    piece_to_move_square = board.get_square(piece_to_move)

    piece_to_move_square.nil? || piece_to_move_square.piece == ' ' || piece_to_move_square.piece.color != curr_player_color ||
      legal_moves_of(piece_to_move).empty?
  end

  def choose_destination(piece_to_move)
    loop do
      board.display
      puts 'Type in where you want to move the piece: '
      destination = gets.chomp
      return destination unless invalid_destination_cords?(piece_to_move, destination)
    end
  end

  def invalid_destination_cords?(piece_to_move, destination)
    piece_to_move_color = board.get_square(piece_to_move).piece.color
    destination_square = board.get_square(destination)

    destination_square.nil? || destination_square.piece != ' ' && destination_square.piece.color == piece_to_move_color ||
      piece_to_move == destination || !legal_moves_of(piece_to_move).include?(destination)
  end

  def same_color?(start, destination)
    start_square = board.get_square(start)
    destination_square = board.get_square(destination)

    destination_square.piece != ' ' && destination_square.piece.color == start_square.piece.color
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

    path.each { |square| return false if square.piece != ' ' && square.cords != destination }

    true
  end

  def invalid_path?(start, destination)
    start_square = board.get_square(start)
    destination_square = board.get_square(start)

    start_square.nil? || destination_square.nil? || start_square.movement.nil? ||
      !start_square.movement.include?(destination) || !path_clear?(start, destination)
  end

  def invalid_move?(start, destination)
    invalid_path?(start, destination) || same_color?(start, destination)
  end

  def legal_moves_of(cords)
    square = board.get_square(cords)

    legal_moves = []

    square.movement.each { |move| legal_moves << move unless invalid_move?(cords, move) }

    if square.piece.is_a? Pawn
      legal_moves = remove_illegal_pawn_moves(cords, legal_moves)
    end

    legal_moves
  end

  def made_double_step_move?(square_cords)
    square = board.get_square(square_cords)
    return false unless square.piece.is_a? Pawn

    previous_move = square.piece.previous_move
    two_backwards = "#{square_cords[0]}#{square_cords[1].to_i + (square.piece.color == 'black' ? 2 : -2)}"

    previous_move == two_backwards
  end
end
