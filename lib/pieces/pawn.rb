# frozen_string_literal: true

require_relative 'piece'

# pawn chess piece
class Pawn < Piece
  attr_accessor :en_passant_counter

  def initialize(color)
    @en_passant_counter = Hash.new(0)
    super
  end

  def unicode
    color == 'black' ? BLACK_PAWN : WHITE_PAWN
  end

  def movement_formula
    color == 'black' ? BLACK_PAWN_MOVEMENT_FORMULA : WHITE_PAWN_MOVEMENT_FORMULA
  end
end
