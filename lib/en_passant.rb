# frozen_string_literal: true

# methods adding functionality for the en passant move
module EnPassant
  def en_passant_moves(cords)
    en_passant_moves = []
    pawn = board.get_square(cords).piece
    if enemy_on_left_of?(cords) && made_double_step_move?(left_of(cords))
      en_passant_move = downwards_from(left_of(cords))
      en_passant_moves << en_passant_move if pawn.en_passant_counter[en_passant_move] < 2
    end
    if enemy_on_right_of?(cords) && made_double_step_move?(right_of(cords))
      en_passant_move = downwards_from(right_of(cords))
      en_passant_moves << en_passant_move if pawn.en_passant_counter[en_passant_move] < 2
    end
    en_passant_moves
  end

  def can_en_passant?(pawn_cords)
    return false unless board.get_square(pawn_cords).piece.is_a? Pawn

    !en_passant_moves(pawn_cords).empty?
  end

  def en_passant_move(pawn_cords, en_passant_move)
    board.get_square(pawn_cords).piece.en_passant_counter = Hash.new(0)
    move(pawn_cords, en_passant_move)
    delete_piece_from(downwards_from(en_passant_move))
  end

  def viable_en_passant_pawn_squares(player_color)
    squares_of(player_color).select { |square| (square.piece.is_a? Pawn) && can_en_passant?(square.cords) }
  end

  def en_passant_counters_increase(player_color)
    viable_en_passant_pawn_squares(player_color).each do |pawn_square|
      en_passant_moves(pawn_square.cords).each do |en_passant_move|
        pawn_square.piece.en_passant_counter[en_passant_move] += 1
      end
    end
  end

  def enemy_on_left_of?(cords)
    square = board.get_square(cords)
    left = board.get_square(left_of(cords))

    return false if board.invalid_cords?(left_of(cords)) || left.empty?

    square_color = square.piece.color
    left_color = left.piece.color

    square_color != left_color
  end

  def enemy_on_right_of?(cords)
    square = board.get_square(cords)
    right = board.get_square(right_of(cords))

    return false if board.invalid_cords?(right_of(cords)) || right.empty?

    square_color = square.piece.color
    right_color = right.piece.color

    square_color != right_color
  end
end
