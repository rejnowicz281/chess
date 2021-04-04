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
end

g = Game.new

loop do
g.play('white')
g.play('black')
end
