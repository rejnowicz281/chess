# frozen_string_literal: true

# chess piece placed on a board square
class Piece
  @@black_unicode = "\u2609"
  @@white_unicode = "\u2609"

  attr_reader :color, :unicode

  def initialize(color)
    @color = color
    @unicode = assign_unicode
  end

  def assign_unicode
    color == 'black' ? @@black_unicode : @@white_unicode
  end
end
