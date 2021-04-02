# frozen_string_literal: true

require_relative 'piece'

# rook chess piece
class Rook < Piece
  def unicode
    color == 'black' ? BLACK_ROOK : WHITE_ROOK
  end

  def movement_formula
    ROOK_MOVEMENT_FORMULA
  end
end
