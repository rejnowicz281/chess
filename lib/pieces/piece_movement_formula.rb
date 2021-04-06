# frozen_string_literal: true

# movement formula every piece
# [x, y] : x - horizontal move | y - vertical move
module PieceMovementFormula
  BLACK_PAWN_MOVEMENT_FORMULA = [[0, -1], [-1, -1], [1, -1], [0, -2]].freeze

  WHITE_PAWN_MOVEMENT_FORMULA = [[0, 1], [-1, 1], [1, 1], [0, 2]].freeze

  ROOK_MOVEMENT_FORMULA = [[0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6], [0, 7], [0, 8],
                           [0, -1], [0, -2], [0, -3], [0, -4], [0, -5], [0, -6], [0, -7], [0, -8],
                           [1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0], [8, 0],
                           [-1, 0], [-2, 0], [-3, 0], [-4, 0], [-5, 0], [-6, 0], [-7, 0], [-8, 0]].freeze

  KNIGHT_MOVEMENT_FORMULA = [[2, 1], [2, -1], [-2, 1], [-2, -1], [1, 2], [1, -2], [-1, 2], [-1, -2]].freeze

  BISHOP_MOVEMENT_FORMULA = [[-1, -1], [-2, -2], [-3, -3], [-4, -4], [-5, -5], [-6, -6], [-7, -7],
                             [1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7],
                             [-1, 1], [-2, 2], [-3, 3], [-4, 4], [-5, 5], [-6, 6], [-7, 7],
                             [1, -1], [2, -2], [3, -3], [4, -4], [5, -5], [6, -6], [7, -7]].freeze

  KING_MOVEMENT_FORMULA = [[0, -1], [0, 1], [1, 0], [-1, 0], [1, -1], [-1, 1], [1, 1], [-1, -1]].freeze

  QUEEN_MOVEMENT_FORMULA = ROOK_MOVEMENT_FORMULA + BISHOP_MOVEMENT_FORMULA
end
