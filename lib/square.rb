# frozen_string_literal: true

Dir['pieces/*.rb'].each { |piece| require_relative piece }

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

  def piece_symbol
    empty? ? piece : piece.unicode
  end

  def empty?
    piece == ' '
  end

  def movement
    return [] if piece == ' '

    movement = []
    piece.movement_formula.each do |formula_cords|
      movement_file_cord = (file_cord.ord + formula_cords[0]).chr
      movement_rank_cord = (rank_cord + formula_cords[1])
      movement << "#{movement_file_cord}#{movement_rank_cord}" unless movement_file_cord.ord < 'a'.ord ||
                                                                      movement_file_cord.ord > 'h'.ord ||
                                                                      movement_rank_cord < 1 || movement_rank_cord > 8
    end
    movement
  end
end
