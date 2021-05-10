# frozen_string_literal: true

# methods adding functionality for the castling move
module Castling
  def castling_moves(king_cords)
    king = board.get_square(king_cords).piece
    return [] unless king.is_a? King

    player_color = king.color
    viable_rooks = viable_castling_rook_squares(player_color).map(&:cords)

    two_left = left_of(king_cords, 2)
    two_right = right_of(king_cords, 2)
    castling_moves = []
    castling_moves << two_left if viable_rooks.include?(left_rook_cords(player_color))
    castling_moves << two_right if viable_rooks.include?(right_rook_cords(player_color))
    castling_moves
  end

  def left_rook_cords(player_color)
    player_color == 'black' ? 'a8' : 'a1'
  end

  def right_rook_cords(player_color)
    player_color == 'black' ? 'h8' : 'h1'
  end

  def castling_move(king_cords, move)
    player_color = board.get_square(king_cords).piece.color
    if left_of(king_cords, 2) == move
      left_rook_castle(left_rook_cords(player_color))
    elsif right_of(king_cords, 2) == move
      right_rook_castle(right_rook_cords(player_color))
    end
  end

  def rook_squares_of(player_color)
    rooks = []
    squares_of(player_color).each { |square| rooks << square if square.piece.is_a? Rook }
    rooks
  end

  def viable_castling_rook_squares(player_color)
    rook_squares_of(player_color).select do |rook_square|
      rook_square.piece.previous_move.nil? && path_clear?(king_cords_of(player_color), rook_square.cords)
    end
  end

  def left_rook_castle(rook_cords)
    player_color = board.get_square(rook_cords).piece.color

    two_left_from_king = left_of(king_cords_of(player_color), 2)
    move(king_cords_of(player_color), two_left_from_king)
    right_from_king = right_of(king_cords_of(player_color))
    move(rook_cords, right_from_king)
  end

  def right_rook_castle(rook_cords)
    player_color = board.get_square(rook_cords).piece.color

    two_right_from_king = right_of(king_cords_of(player_color), 2)
    move(king_cords_of(player_color), two_right_from_king)
    left_from_king = left_of(king_cords_of(player_color))
    move(rook_cords, left_from_king)
  end
end
