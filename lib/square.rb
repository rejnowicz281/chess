# frozen_string_literal: true

# square used in board
class Square
  attr_reader :cords, :piece, :file_cord, :rank_cord

  def initialize(file_cord, rank_cord, piece = ' ')
    @cords = "#{file_cord}#{rank_cord}"
    @piece = piece
    @file_cord = file_cord
    @rank_cord = rank_cord
  end

  def remove_piece
    self.piece = ' '
  end

  def place_piece(piece)
    self.piece = piece
  end
end
