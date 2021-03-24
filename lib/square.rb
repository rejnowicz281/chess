# frozen_string_literal: true

# node used in board
class Square
  attr_reader :cords, :column_cord, :row_cord
  attr_accessor :piece

  def initialize(column_cord, row_cord, piece = ' ')
    @cords = "#{column_cord}#{row_cord}"
    @piece = piece
    @column_cord = column_cord
    @row_cord = row_cord
  end

  def remove_piece
    self.piece = ' '
  end
end
