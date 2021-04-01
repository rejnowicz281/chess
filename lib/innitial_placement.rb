# frozen_string_literal: true

# methods to place pieces on their innitial locations
module InnitialPlacement
  def place_pieces
    place_rooks
    place_knights
    place_bishops
    place_queens
    place_kings
    place_pawns
  end

  def place_rooks
    board.squares.each do |square|
      case square.cords
      when 'a8'
        square.piece = Rook.new('black')
      when 'h8'
        square.piece = Rook.new('black')
      when 'a1'
        square.piece = Rook.new('white')
      when 'h1'
        square.piece = Rook.new('white')
      end
    end
  end

  def place_knights
    board.squares.each do |square|
      case square.cords
      when 'b8'
        square.piece = Knight.new('black')
      when 'g8'
        square.piece = Knight.new('black')
      when 'b1'
        square.piece = Knight.new('white')
      when 'g1'
        square.piece = Knight.new('white')
      end
    end
  end

  def place_bishops
    board.squares.each do |square|
      case square.cords
      when 'c8'
        square.piece = Bishop.new('black')
      when 'f8'
        square.piece = Bishop.new('black')
      when 'c1'
        square.piece = Bishop.new('white')
      when 'f1'
        square.piece = Bishop.new('white')
      end
    end
  end

  def place_queens
    board.squares.each do |square|
      case square.cords
      when 'd8'
        square.piece = Queen.new('black')
      when 'd1'
        square.piece = Queen.new('white')
      end
    end
  end

  def place_kings
    board.squares.each do |square|
      case square.cords
      when 'e8'
        square.piece = King.new('black')
      when 'e1'
        square.piece = King.new('white')
      end
    end
  end

  def place_pawns
    black_pawn_locations = %w[a7 b7 c7 d7 e7 f7 g7 h7]
    white_pawn_locations = %w[a2 b2 c2 d2 e2 f2 g2 h2]

    board.squares.each do |square|
      if black_pawn_locations.include?(square.cords)
        square.piece = Pawn.new('black')
      elsif white_pawn_locations.include?(square.cords)
        square.piece = Pawn.new('white')
      end
    end
  end
end