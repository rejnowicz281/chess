# frozen_string_literal: true

require_relative 'piece'

# bishop chess piece
class Bishop < Piece
  def unicode
    color == 'black' ? BLACK_BISHOP : WHITE_BISHOP
  end
end
