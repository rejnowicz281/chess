# frozen_string_literal: true

require_relative 'square'

# game board
class Board
  attr_accessor :squares

  def initialize
    @squares = squares_array
  end

  def squares_array
    squares = []
    file_cord = 'a'
    rank_cord = 8

    until squares.length == 8 * 8
      square = Square.new(file_cord, rank_cord)
      squares << square

      file_cord = (file_cord.ord + 1).chr

      if file_cord == 'i'
        rank_cord -= 1
        file_cord = 'a'
      end
    end

    squares
  end

  def display
    print_file_cords

    print_board

    print_file_cords
  end

  def print_file_cords
    ('a'..'h').to_a.each { |letter| print "    #{letter}" }
    puts
  end

  def print_board
    8.downto(1) { |i| puts rank(i) }
  end

  def rank_squares(i)
    rank_squares = []
    squares.each { |square| rank_squares << square if square.rank_cord == i }
    rank_squares
  end

  def rank(i)
    rank = []

    rank_squares(i).each do |rank_square|
      rank << case rank_square.file_cord
              when 'a'
                "#{rank_square.rank_cord} [ #{rank_square.piece} ]"
              when 'h'
                "[ #{rank_square.piece} ] #{rank_square.rank_cord}"
              else
                "[ #{rank_square.piece} ]"
              end
    end

    rank.join
  end

  def get_square(cords)
    square.each { |square| return square if square.cords == cords }
    nil
  end
end
