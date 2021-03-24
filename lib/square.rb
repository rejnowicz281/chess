# frozen_string_literal: true

# square used in board
class Square
  attr_reader :cords, :file_cord, :rank_cord
  attr_accessor :piece

  def initialize(file_cord, rank_cord, piece = ' ')
    @cords = "#{file_cord}#{rank_cord}"
    @piece = piece
    @file_cord = file_cord
    @rank_cord = rank_cord
  end

  def remove_piece
    self.piece = ' '
  end
end
