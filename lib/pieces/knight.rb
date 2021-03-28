# frozen_string_literal: true

require_relative 'piece'

# knight chess piece
class Knight < Piece
  def unicode
    color == 'black' ? BLACK_KNIGHT : WHITE_KNIGHT
  end
end
