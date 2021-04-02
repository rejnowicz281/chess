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
                "#{rank_square.rank_cord} [ #{rank_square.piece_symbol} ]"
              when 'h'
                "[ #{rank_square.piece_symbol} ] #{rank_square.rank_cord}"
              else
                "[ #{rank_square.piece_symbol} ]"
              end
    end

    rank.join
  end

  def get_square(cords)
    squares.each { |square| return square if square.cords == cords }
    nil
  end

  def path(start, destination)
    path = []
    curr_square = get_square(start)

    until curr_square.cords == destination
      if curr_square.cords[0].ord < destination[0].ord
        new_file = (curr_square.cords[0].ord + 1).chr
      elsif curr_square.cords[0].ord > destination[0].ord
        new_file = (curr_square.cords[0].ord - 1).chr
      else
        new_file = curr_square.cords[0]
      end

      if curr_square.cords[1].to_i < destination[1].to_i
        new_rank = "#{curr_square.cords[1].to_i + 1}"
      elsif curr_square.cords[1].to_i > destination[1].to_i
        new_rank = "#{curr_square.cords[1].to_i - 1}"
      else
        new_rank = curr_square.cords[1]
      end

      new_cords = "#{new_file}#{new_rank}"
      curr_square = get_square(new_cords)

      path << curr_square
    end
    path
  end

  def path_clear?(start, destination)
    path = path(start, destination)

    path.each { |square| return false if square.piece != ' ' }

    true
  end

  def invalid_path?(start, destination)
    get_square(start).nil? || get_square(destination).nil? || get_square(start).movement.nil? ||
      !get_square(start).movement.include?(destination) || !path_clear?(start, destination)
  end
end
