# frozen_string_literal: true

require_relative 'node'

# game board
class Board
  attr_reader :size
  attr_accessor :nodes

  def initialize(size = 8)
    @size = size
    @nodes = assign_nodes
  end

  def assign_nodes
    nodes = []
    letter_cord = 'a'
    off_board_letter = (letter_cord.ord + size).chr
    num_cord = size

    until nodes.length == size * size
      node = Node.new("#{letter_cord}#{num_cord}")
      nodes << node
      letter_cord = (letter_cord.ord + 1).chr

      if letter_cord == off_board_letter
        num_cord -= 1       # push in nodes with proper coordinates
        letter_cord = 'a'
      end
    end

    nodes
  end

  def show_board
    print_letter_cords

    nodes.each do |node|
      case node.cords[0]
      when 'a'
        print " #{node.cords[1]} [ #{node.piece} ]"
      when nodes.last.cords[0]
        puts "[ #{node.piece} ] #{node.cords[1]}"
      else
        print "[ #{node.piece} ]"
      end
    end

    print_letter_cords
  end

  def get_node(cords)
    nodes.each { |node| return node if node.cords == cords }
    nil
  end

  def print_letter_cords
    letter_cords = ('a'..nodes.last.cords[0]).to_a
    letter_cords.each { |letter| print letter == 'a' ?  "     #{letter}" : "    #{letter}" }
    puts
  end
end

b = Board.new

b.show_board