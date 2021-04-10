# frozen_string_literal: true

# methods to give pawn correct behaviour depending on the neigbouring pieces
module PawnBehaviour
  def remove_illegal_pawn_moves(cords, legal_moves)
    pawn_square = board.get_square(cords)

    one_forward_cords = one_forward_from(cords)
    one_forward_square = board.get_square(one_forward_cords)

    two_forward_cords = two_forward_from(cords)

    forward_left_cords = forward_left_of(cords)
    forward_left_square = board.get_square(forward_left_cords)

    forward_right_cords = forward_right_of(cords)
    forward_right_square = board.get_square(forward_right_cords)

    legal_moves -= [one_forward_cords] unless one_forward_square.piece == ' '

    legal_moves -= [two_forward_cords] unless pawn_square.piece.previous_move.nil?

    legal_moves -= [forward_left_cords] if !forward_left_square.nil? &&
                                           (forward_left_square.piece == ' ' ||
                                           forward_left_square.piece.color == pawn_square.piece.color)

    legal_moves -= [forward_right_cords] if !forward_right_square.nil? &&
                                            (forward_right_square.piece == ' ' ||
                                            forward_right_square.piece.color == pawn_square.piece.color)

    legal_moves
  end

  def one_forward_from(cords)
    rank = board.get_square(cords).piece.color == 'black' ? (cords[1].to_i - 1) : (cords[1].to_i + 1)
    "#{cords[0]}#{rank}"
  end

  def two_forward_from(cords)
    rank = board.get_square(cords).piece.color == 'black' ? (cords[1].to_i - 2) : (cords[1].to_i + 2)
    "#{cords[0]}#{rank}"
  end

  def forward_left_of(cords)
    file = (cords[0].ord - 1).chr
    rank = board.get_square(cords).piece.color == 'black' ? (cords[1].to_i - 1) : (cords[1].to_i + 1)
    "#{file}#{rank}"
  end

  def forward_right_of(cords)
    file = (cords[0].ord + 1).chr
    rank = board.get_square(cords).piece.color == 'black' ? (cords[1].to_i - 1) : (cords[1].to_i + 1)
    "#{file}#{rank}"
  end
end
