# frozen_string_literal: true

require_relative 'piece'

# pawn chess piece
class Pawn < Piece
  def unicode
    color == 'black' ? BLACK_PAWN : WHITE_PAWN
  end

  def movement_formula
    case previous_move
    when nil
      color == 'black' ? BLACK_PAWN_FIRST_MOVE_FORMULA : WHITE_PAWN_FIRST_MOVE_FORMULA
    else
      color == 'black' ? BLACK_PAWN_MOVEMENT_FORMULA : WHITE_PAWN_MOVEMENT_FORMULA
    end
  end

  def capturing_movement_formula
    color == 'black' ? BLACK_PAWN_CAPTURING_MOVEMENT_FORMULA : WHITE_PAWN_CAPTURING_MOVEMENT_FORMULA
  end
end
