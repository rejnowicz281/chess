# frozen_string_literal: true

require_relative 'chess_symbols'
require_relative 'piece_movement_formula'

# piece placed on a board square
class Piece
  include ChessSymbols
  include PieceMovementFormula

  attr_reader :color
  attr_accessor :cords

  def initialize(color = 'white')
    @color = color
  end
end
