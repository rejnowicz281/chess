# frozen_string_literal: true

require_relative 'board'
require_relative 'innitial_placement'
Dir['pieces/*.rb'].each { |piece| require_relative piece }

# game class
class Game
  include InnitialPlacement
  attr_reader :board

  def initialize
    @board = Board.new
    place_pieces
  end

  def play_turn(curr_player_color)
    board.display
    puts "Current player: #{curr_player_color}."
    move = input_move
    start = move.split('-').first
    destination = move.split('-').last
    puts "Legal moves: #{legal_moves_of(start).join(' ')}"

    return play_turn(curr_player_color) unless legal_moves_of(start).include?(destination)

    move(start, destination)
  end

  def input_move
    puts 'Type in your move. For example: a2-a3'
    gets.chomp
  end

  def invalid_move?(curr_player_color, start, destination)
    start_square = board.get_square(start)
    destination_square = board.get_square(destination)

    invalid_path?(start, destination) || start_square.piece.color != curr_player_color ||
      destination_square.piece != ' ' && destination_square.piece.color == curr_player_color
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

    path.each { |square| return false if square.piece != ' ' }

    true
  end

  def invalid_path?(start, destination)
    start_square = board.get_square(start)
    destination_square = board.get_square(start)

    start_square.nil? || destination_square.nil? || start_square.movement.nil? ||
      !start_square.movement.include?(destination) || !path_clear?(start, destination)
  end

  def legal_moves_of(cords)
    square = board.get_square(cords)
    legal_moves = []

    square.movement.each { |move| legal_moves << move unless invalid_move?(square.piece.color, square.cords, move) }

    legal_moves
  end
end

g = Game.new

loop do
g.play_turn('white')
g.play_turn('black')
end
