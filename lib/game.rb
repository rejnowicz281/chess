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
end
