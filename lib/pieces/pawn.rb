# frozen_string_literal: true

require_relative 'piece'

# pawn chess piece
class Pawn < Piece
  def unicode
    color == 'black' ? BLACK_PAWN : WHITE_PAWN
  end
end
