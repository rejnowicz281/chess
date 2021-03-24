# frozen_string_literal: true

require_relative 'node'

# game board
class Board
  attr_accessor :nodes

  def initialize
    @nodes = nodes_array
  end

  def nodes_array
    nodes = []
    column_cord = 'a'
    row_cord = 8

    until nodes.length == 8 * 8
      node = Node.new(column_cord, row_cord)
      nodes << node

      column_cord = (column_cord.ord + 1).chr

      if column_cord == 'i'
        row_cord -= 1
        column_cord = 'a'
      end
    end

    nodes
  end

  def display
    print_column_cords

    print_board

    print_column_cords
  end

  def print_column_cords
    ('a'..'h').to_a.each { |letter| print "    #{letter}" }
    puts
  end

  def print_board
    8.downto(1) { |i| puts row(i) }
  end

  def row_nodes(i)
    row_nodes = []
    nodes.each { |node| row_nodes << node if node.row_cord == i }
    row_nodes
  end

  def row(i)
    row = []

    row_nodes(i).each do |row_node|
      row << case row_node.column_cord
             when 'a'
               "#{row_node.row_cord} [ #{row_node.piece} ]"
             when 'h'
               "[ #{row_node.piece} ] #{row_node.row_cord}"
             else
               "[ #{row_node.piece} ]"
             end
    end

    row.join
  end

  def get_node(cords)
    nodes.each { |node| return node if node.cords == cords }
    nil
  end
end
