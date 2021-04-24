# frozen_string_literal: true

require_relative 'piece'

# king chess piece
class King < Piece
  attr_accessor :in_check_counter

  def initialize(color)
    @in_check_counter = 0
    super
  end

  def unicode
    color == 'black' ? BLACK_KING : WHITE_KING
  end

  def movement_formula
    KING_MOVEMENT_FORMULA
  end
end
