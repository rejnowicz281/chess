# frozen_string_literal: true

require_relative 'piece'

# king chess piece
class King < Piece
  def unicode
    color == 'black' ? BLACK_KING : WHITE_KING
  end
end
