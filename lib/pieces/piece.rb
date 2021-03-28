# frozen_string_literal: true

require_relative 'chess_symbols'

# piece placed on a board square
class Piece
  include ChessSymbols
  attr_reader :color

  def initialize(color)
    @color = color
  end
end
