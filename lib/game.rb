# frozen_string_literal: true

require_relative 'board'
require_relative 'innitial_placement'
Dir['pieces/*.rb'].each { |piece| require_relative piece }

# game class
class Game
  include InnitialPlacement
  include PawnBehaviour
  attr_reader :board
  attr_accessor :save_popup

  def initialize
    Dir.mkdir('saves') unless Dir.exist?('saves')
    @save_popup = true
    @board = Board.new
    place_pieces
  end

  def human_round
    loop do
      play_turn('white')
      if checkmated?('white')
        puts 'Black wins'
        return
      elsif checkmated?('black')
        puts 'White wins'
        return
      end

      play_turn('black')
      if checkmated?('white')
        puts 'Black wins'
        return
      elsif checkmated?('black')
        puts 'White wins'
        return
      end
    end
  end

  def computer_round
    loop do
      play_turn('white')
      if checkmated?('white')
        puts 'Black wins'
        return
      elsif checkmated?('black')
        puts 'White wins'
        return
      end

      computer_turn('black')
      if checkmated?('white')
        puts 'Black wins'
        return
      elsif checkmated?('black')
        puts 'White wins'
        return
      end
    end
  end

  def play_round
    game_type = choose_game_type
    if game_type == 'human'
      human_round
    else
      computer_round
    end
  end

  def choose_game_type
    print 'Type in 1 if you want to play against a human. Type 2 if you want to play against a computer: '
    choice = gets.chomp
    case choice
    when '1'
      'human'
    when '2'
      'computer'
    end
  end

  def computer_turn(player_color)
    viable_en_passant_pawn_squares(player_color).each do |pawn_square|
      en_passant_moves(pawn_square.cords).each do |en_passant_move|
        pawn_square.piece.en_passant_counter[en_passant_move] += 1
      end
    end
    player_king = king_square_of(player_color).piece

    player_king.in_check_counter += 1 if king_in_check?(player_color)

    puts "Current player: #{player_color}."

    moving_piece = viable_pieces_to_move(player_color).sample
    print "\nI'm moving #{moving_piece} ---> "

    destination = legal_moves_of(moving_piece).sample
    print "#{destination}\n\n"
    move(moving_piece, destination)

    promote(destination, 'queen') if promotion?(destination)

    player_king.in_check_counter += 1 if king_in_check?(player_color)
    player_king.in_check_counter = 0 if player_king.in_check_counter == 1 && !king_in_check?(player_color)
  end

  def play
    if no_saved_games?
      play_round
    else
      load_prompt
    end
  end

  def play_turn(player_color)
    viable_en_passant_pawn_squares(player_color).each do |pawn_square|
      en_passant_moves(pawn_square.cords).each do |en_passant_move|
        pawn_square.piece.en_passant_counter[en_passant_move] += 1
      end
    end
    board.display
    player_king = king_square_of(player_color).piece

    player_king.in_check_counter += 1 if king_in_check?(player_color)

    puts "Current player: #{player_color}."

    p king_in_check?(player_color) ? 'You are in check. Defend your king!' : 'You are NOT in check.'
    p "In check counter: #{player_king.in_check_counter}. once it reaches 2, you lose"

    save_prompt if save_popup

    moving_piece = input_moving_piece(player_color)

    if moving_piece == king_cords_of(player_color) && can_castle?(player_color)
      puts 'You can castle. Type yes if you want to castle:'
      choice = gets.chomp
      return castling_prompt(player_color) if choice == 'yes'
    elsif can_en_passant?(moving_piece)
      puts 'You can capture en passant. Type yes if you want to:'
      choice = gets.chomp
      return en_passant_prompt(moving_piece) if choice == 'yes'
    end

    puts "Legal moves: #{legal_moves_of(moving_piece)}"

    destination = input_destination(moving_piece)

    move(moving_piece, destination)

    promotion_prompt(destination) if promotion?(destination)

    player_king.in_check_counter += 1 if king_in_check?(player_color)
    player_king.in_check_counter = 0 if player_king.in_check_counter == 1 && !king_in_check?(player_color)
  end

  def enable_save_popup?
    print 'Type 1 if you would like to enable save popup: '
    choice = gets.chomp
    self.save_popup = true if choice == '1'
  end

  def load_prompt
    print 'Type 1 if you would like to load a save: '
    choice = gets.chomp
    case choice
    when '1'
      puts 'Available saves: '
      saves_array = Dir.children('saves')
      saves_array.each { |save| puts save }
      loop do
        print 'Type in index of a save to load it: '
        save_index = gets.chomp
        save_index = save_index.to_i
        next unless save_index < saves_array.length

        load_save(save_index)
      end
    else
      play_round
    end
  end

  def load_save(save_index)
    save = File.read("saves/save#{save_index}.marshal")
    new_game = Marshal::load(save)
    puts 'Game loaded.'
    new_game.play_round
  end

  def save_prompt
    print 'Would you like to save the game?(1-yes, 2-dont ask): '
    choice = gets.chomp
    case choice
    when '1'
      save_game
    when '2'
      self.save_popup = false
    end
  end

  def no_saved_games?
    Dir.children('saves').empty?
  end

  def save_game
    saves_array = Dir.children('saves')
    save = File.new("saves/save#{saves_array.length}.marshal", 'w')
    save.write "#{Marshal::dump(self)}"
    save.close
  end

  def input_moving_piece(player_color)
    loop do
      puts 'Type in cords of the piece you want to move: '
      moving_piece = gets.chomp
      return moving_piece if viable_pieces_to_move(player_color).include?(moving_piece)
    end
  end

  def viable_pieces_to_move(player_color)
    player_piece_cords = squares_of(player_color).map(&:cords)
    player_piece_cords.reject { |piece_cords| legal_moves_of(piece_cords).empty? }
  end

  def input_destination(moving_piece)
    loop do
      puts 'Type in where you want to move the piece: '
      destination = gets.chomp
      return destination if legal_moves_of(moving_piece).include?(destination)
    end
  end

  def same_color?(square1_cords, square2_cords)
    square1 = board.get_square(square1_cords)
    square2 = board.get_square(square2_cords)

    !square2.empty? && square2.piece.color == square1.piece.color
  end

  def move(start, destination)
    start_square = board.get_square(start)
    destination_square = board.get_square(destination)

    destination_square.piece = start_square.piece
    destination_square.piece.previous_move = start
    delete_piece_from(start)
  end

  def path_clear?(start, destination)
    return true if board.get_square(start).piece.is_a? Knight

    path = board.path(start, destination)

    path.each { |square| return false if !square.empty? && square.cords != destination }

    true
  end

  def invalid_path?(start, destination)
    return true if board.invalid_cords?(start) || board.invalid_cords?(destination)

    start_square = board.get_square(start)

    start_square.movement.nil? || !start_square.movement.include?(destination) || !path_clear?(start, destination)
  end

  def legal_moves_of(cords)
    square = board.get_square(cords)

    legal_moves = []

    square.movement.each { |move| legal_moves << move unless illegal_move?(cords, move) }

    legal_moves -= illegal_pawn_moves(cords) if square.piece.is_a? Pawn

    legal_moves
  end

  def illegal_move?(start, destination)
    invalid_path?(start, destination) || same_color?(start, destination)
  end

  def made_double_step_move?(cords)
    square = board.get_square(cords)
    return false unless square.piece.is_a? Pawn

    previous_move = square.piece.previous_move
    two_downwards = downwards_from(cords, 2)

    previous_move == two_downwards
  end

  def left_of(cords, i = 1)
    "#{(cords[0].ord - i).chr}#{cords[1]}"
  end

  def right_of(cords, i = 1)
    "#{(cords[0].ord + i).chr}#{cords[1]}"
  end

  def downwards_from(cords, i = 1)
    color = board.get_square(cords).piece.color
    "#{cords[0]}#{cords[1].to_i + (color == 'black' ? i : -i)}"
  end

  def forwards_from(cords, i = 1)
    color = board.get_square(cords).piece.color
    "#{cords[0]}#{cords[1].to_i + (color == 'black' ? -i : i)}"
  end

  def enemy_on_left_of?(cords)
    square = board.get_square(cords)
    left = board.get_square(left_of(cords))

    return false if board.invalid_cords?(left_of(cords)) || left.empty?

    square_color = square.piece.color
    left_color = left.piece.color

    square_color != left_color
  end

  def enemy_on_right_of?(cords)
    square = board.get_square(cords)
    right = board.get_square(right_of(cords))

    return false if board.invalid_cords?(right_of(cords)) || right.empty?

    square_color = square.piece.color
    right_color = right.piece.color

    square_color != right_color
  end

  def en_passant_moves(cords)
    en_passant_moves = []
    pawn = board.get_square(cords).piece
    if enemy_on_left_of?(cords) && made_double_step_move?(left_of(cords))
      en_passant_move = downwards_from(left_of(cords))
      en_passant_moves << en_passant_move if pawn.en_passant_counter[en_passant_move] < 2
    end
    if enemy_on_right_of?(cords) && made_double_step_move?(right_of(cords))
      en_passant_move = downwards_from(right_of(cords))
      en_passant_moves << en_passant_move if pawn.en_passant_counter[en_passant_move] < 2
    end
    en_passant_moves
  end

  def can_en_passant?(pawn_cords)
    return false unless board.get_square(pawn_cords).piece.is_a? Pawn

    !en_passant_moves(pawn_cords).empty?
  end

  def en_passant_prompt(pawn_cords)
    loop do
      puts "Possible en passant moves: #{en_passant_moves(pawn_cords)}"
      puts 'Type in your move: '
      en_passant_move = gets.chomp
      return en_passant(pawn_cords, en_passant_move) if en_passant_moves(pawn_cords).include?(en_passant_move)
    end
  end

  def en_passant(pawn_cords, en_passant_move)
    board.get_square(pawn_cords).piece.en_passant_counter = Hash.new(0)
    move(pawn_cords, en_passant_move)
    delete_piece_from(downwards_from(en_passant_move))
  end

  def viable_en_passant_pawn_squares(player_color)
    squares_of(player_color).select { |square| can_en_passant?(square.cords) }
  end

  def squares_of(player_color)
    player_squares = []
    board.squares.each do |square|
      player_squares << square if !square.empty? && square.piece.color == player_color
    end
    player_squares
  end

  def king_square_of(player_color)
    squares_of(player_color).each { |square| return square if square.piece.is_a? King }
  end

  def king_cords_of(player_color)
    squares_of(player_color).each { |square| return square.cords if square.piece.is_a? King }
  end

  def can_be_captured?(piece_cords)
    player_square = board.get_square(piece_cords)
    return false if player_square.empty?

    player_color = player_square.piece.color
    enemy_color = player_color == 'black' ? 'white' : 'black'
    enemy_squares = squares_of(enemy_color)

    enemy_squares.each do |enemy_square|
      enemy_legal_moves = legal_moves_of(enemy_square.cords)
      return true if enemy_legal_moves.include?(piece_cords)
    end
    false
  end

  def king_in_check?(player_color)
    king_cords = king_square_of(player_color).cords
    can_be_captured?(king_cords)
  end

  def checkmated?(player_color)
    player_king = king_square_of(player_color).piece

    player_king.in_check_counter == 2
  end

  def rook_squares_of(player_color)
    rooks = []
    squares_of(player_color).each { |square| rooks << square if square.piece.is_a? Rook }
    rooks
  end

  def castling_prompt(player_color)
    loop do
      viable_rook_cords = viable_castling_rook_squares(player_color).map(&:cords)
      puts "Viable rook cords: #{viable_rook_cords}"
      puts 'Type in the rook you want to castle with: '
      rook_cords = gets.chomp
      return castle_with(rook_cords) if viable_rook_cords.include?(rook_cords)
    end
  end

  def viable_castling_rook_squares(player_color)
    rook_squares_of(player_color).select do |rook_square|
      rook_square.piece.previous_move.nil? && path_clear?(king_cords_of(player_color), rook_square.cords)
    end
  end

  def can_castle?(player_color)
    return false if rook_squares_of(player_color).empty?

    player_king = king_square_of(player_color).piece
    viable_rooks = viable_castling_rook_squares(player_color)

    player_king.previous_move.nil? && !king_in_check?(player_color) && !viable_rooks.empty?
  end

  def castle_with(rook_cords)
    if left_rook?(rook_cords)
      left_rook_castle(rook_cords)
    elsif right_rook?(rook_cords)
      right_rook_castle(rook_cords)
    end
  end

  def left_rook?(rook_cords)
    %w[a1 a8].include?(rook_cords)
  end

  def right_rook?(rook_cords)
    %w[h1 h8].include?(rook_cords)
  end

  def left_rook_castle(rook_cords)
    player_color = board.get_square(rook_cords).piece.color

    two_left_from_king = left_of(king_cords_of(player_color), 2)
    move(king_cords_of(player_color), two_left_from_king)
    right_from_king = right_of(king_cords_of(player_color))
    move(rook_cords, right_from_king)
  end

  def right_rook_castle(rook_cords)
    player_color = board.get_square(rook_cords).piece.color

    two_right_from_king = right_of(king_cords_of(player_color), 2)
    move(king_cords_of(player_color), two_right_from_king)
    left_from_king = left_of(king_cords_of(player_color))
    move(rook_cords, left_from_king)
  end

  def place(cords, piece)
    board.get_square(cords).piece = piece
  end

  def delete_piece_from(square_cords)
    board.get_square(square_cords).piece = ' '
  end

  def promotion?(pawn_cords)
    return false unless board.get_square(pawn_cords).piece.is_a? Pawn

    pawn_rank = board.get_square(pawn_cords).rank_cord
    pawn_color = board.get_square(pawn_cords).piece.color

    pawn_rank == if pawn_color == 'black'
                   1
                 else
                   8
                 end
  end

  def promotion_prompt(pawn_cords)
    loop do
      puts 'Your pawn must promote. Type in a piece of your choice to promote to it: '
      promotion_pieces = %w[queen rook bishop knight]
      promotion_piece = gets.chomp
      return promote(pawn_cords, promotion_piece) if promotion_pieces.include?(promotion_piece)
    end
  end

  def promote(pawn_cords, promotion_piece)
    pawn_color = board.get_square(pawn_cords).piece.color
    board.get_square(pawn_cords).piece = case promotion_piece
                                         when 'queen'
                                           Queen.new(pawn_color)
                                         when 'rook'
                                           Rook.new(pawn_color)
                                         when 'bishop'
                                           Bishop.new(pawn_color)
                                         when 'knight'
                                           Knight.new(pawn_color)
                                         end
    puts "Promotion to #{promotion_piece}."
  end
end

g = Game.new

g.play
