# tic_tac_toe.rb
require 'pry'
require 'pry-byebug'
POSSIBLE_INDICES = [1, 2, 3]

def new_board
  [
    ['___', '|', '___', '|', '___'],
    ['___', '|', '___', '|', '___'],
    ['   ', '|', '   ', '|', '   ']
  ]
end

def print_board(board)
  board.each do |row|
    row.each do |element|
      print element
    end
    puts
  end
end

def valid_move?(board, position)
  current_mark = board[position[0] - 1][(position[1] - 1) * 2][1]
  return false if ['X', 'O'].include?(current_mark)
  true
end

def mark_board(board, player, position)
  mark = player == 'player' ? 'X' : 'O'

  board[position[0] - 1][(position[1] - 1) * 2] = if position[0] == 3
                                                    ' ' + mark + ' '
                                                  else
                                                    '_' + mark + '_'
                                                  end
end

def player_turn(board)
  position = []

  loop do
    puts 'Please enter the desired row from 1 (top of the board) " +
      to 3 (bottom of the board)'
    position[0] = gets.chomp.to_i

    puts 'Now please enter the desired column from 1 (left side) " +
      to 3 (right side)'
    position[1] = gets.chomp.to_i

    break if valid_move?(board, position)
    puts 'I\'m sorry, the requested move is unavailable. Please try again.'
  end

  puts 'Thank you!'
  mark_board(board, 'player', position)

  puts 'After your turn, the board state is:'
  print_board(board)
end

def computer_turn(board)
  valid_position = false
  until valid_position
    position = [POSSIBLE_INDICES.sample, POSSIBLE_INDICES.sample]
    valid_position = valid_move?(board, position)
  end

  mark_board(board, 'computer', position)
  puts 'Now it\'s the computer\'s turn!'
  puts 'The new board state is:'
  print_board(board)
end

def extract_row(board, index)
  squares = board[index].select.with_index do |_, idx|
    idx.even?
  end
  squares.map { |square| square[1] }
end

def extract_column(board, index)
  board.map { |row| row[index * 2] }.map { |square| square[1] }
end

def extract_diagonals(board)
  diagonals = [[], []]

  board.each.with_index do |_, idx|
    diagonals[0] << board[idx][idx * 2][1]
    diagonals[1] << board[idx][(2 - idx) * 2][1]
  end

  diagonals
end

def get_column_winner(board, idx)
  column = extract_column(board, idx)
  if column.uniq.size == 1
    return 'player' if column.uniq[0] == 'X'
    return 'computer' if column.uniq[0] == 'O'
  end
  nil
end

def get_row_winner(board, idx)
  row = extract_row(board, idx)
  if row.uniq.size == 1
    return 'player' if row.uniq[0] == 'X'
    return 'computer' if row.uniq[0] == 'O'
  end
  nil
end

def get_diagonal_winner(board)
  diagonals = extract_diagonals(board)
  diagonals.each do |diagonal|
    if diagonal.uniq.size == 1
      return 'player' if diagonal.uniq[0] == 'X'
      return 'computer' if diagonal.uniq[0] == 'O'
    end
  end
  nil
end

def check_winner(board)
  winner = nil

  board.each_index do |idx|
    column_winner = get_column_winner(board, idx)
    row_winner = get_row_winner(board, idx)

    winner = column_winner unless column_winner.nil?
    winner = row_winner unless row_winner.nil?
  end

  diagonal_winner = get_diagonal_winner(board)
  winner = diagonal_winner unless diagonal_winner.nil?

  winner
end

def board_full?(board)
  rows = []

  board.each_index do |idx|
    rows << extract_row(board, idx)
    rows << extract_column(board, idx)
  end

  rows += extract_diagonals(board)
  rows.all? do |row|
    row.none? { |square| [' ', '_'].include?(square) }
  end
end

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
def play_game
  loop do
    board = new_board

    loop do
      player_turn(board)
      winner = check_winner(board)
      if winner
        puts 'Game over!'
        puts "#{winner.capitalize} has won the game."
        break
      end

      if board_full?(board)
        puts "Game over!"
        puts "It's a tie."
        break
      end

      computer_turn(board)
      winner = check_winner(board)
      if winner
        puts 'Game over!'
        puts "#{winner.capitalize} has won the game."
        break
      end

      if board_full?(board)
        puts "Game over!"
        puts "It's a tie."
        break
      end
    end

    puts "Would you like to play again? (y/n)"
    play_again = gets.chomp
    break if play_again.downcase == 'n'
  end

  puts 'Thanks for playing. Goodbye!'
end
# rubocop:enable Metrics/MethodLength, Metrics/AbcSize

play_game
