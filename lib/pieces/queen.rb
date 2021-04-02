# frozen_string_literal: true

require_relative 'piece'

# queen chess piece
class Queen < Piece
  def unicode
    color == 'black' ? BLACK_QUEEN : WHITE_QUEEN
  end

  def movement_formula
    QUEEN_MOVEMENT_FORMULA
  end
end
