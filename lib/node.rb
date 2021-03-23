# frozen_string_literal: true

# node used in board
class Node
  attr_reader :cords
  attr_accessor :piece

  def initialize(cords, piece = ' ')
    @cords = cords
    @piece = piece
  end

  def remove_piece
    self.piece = ' '
  end
end
