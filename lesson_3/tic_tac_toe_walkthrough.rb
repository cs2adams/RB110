# tic_tac_toe_walkthrough.rb
require 'pry'
require 'pry-byebug'
WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                [[1, 5, 9], [3, 5, 7]]              # diagonals

INITIAL_MARKER = ' '
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'
PLAYERS = ['Player', 'Computer']

def prompt(msg)
  puts "=> #{msg}"
end

def joinor(arr, delimeter = ', ', oxford_word = 'or')
  return '' if arr.size == 0
  return arr[0].to_s if arr.size == 1
  "#{arr[0..-2].join(delimeter)}#{delimeter[0] if arr.size > 2} " \
    "#{oxford_word} #{arr[-1]}"
end

def choose_first_player
  prompt("Would you like to go first? Please enter 'y' for yes, 'n' for no " \
    "or 'r' for randomize")
  first_player_choice = gets.chomp

  case first_player_choice.downcase[0]
  when 'y' then 'Player'
  when 'n' then 'Computer'
  else ['Player', 'Computer'].sample
  end
end

# rubocop:disable Metrics/AbcSize
def display_board(brd)
  system('clear')
  puts "You're a #{PLAYER_MARKER}. Computer is #{COMPUTER_MARKER}."
  puts "     |     |"
  puts "  #{brd[1]}  |  #{brd[2]}  |  #{brd[3]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{brd[4]}  |  #{brd[5]}  |  #{brd[6]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{brd[7]}  |  #{brd[8]}  |  #{brd[9]}"
  puts "     |     |"
  puts ""
end
# rubocop:enable Metrics/AbcSize

def initialize_board
  new_board = {}
  (1..9).each { |num| new_board[num] = INITIAL_MARKER }
  new_board
end

def initialize_score
  { Player: 0, Computer: 0 }
end

def empty_squares(brd)
  brd.keys.select { |num| brd[num] == INITIAL_MARKER }
end

def alternate_player(current_player)
  PLAYERS.select { |player| player != current_player }.first
end

def player_places_piece!(brd)
  square = ''
  loop do
    prompt "Choose a square (#{joinor(empty_squares(brd))}):"
    square = gets.chomp.to_i
    break if empty_squares(brd).include?(square)
    prompt "Sorry, that's not a valid choice."
  end

  brd[square] = PLAYER_MARKER
end

def computer_minimaxes_move!(brd)
  _, square = minimax(brd)
  brd[square] = COMPUTER_MARKER
end

def algo_places_piece!(brd, square, player)
  marker = player == 'Player' ? PLAYER_MARKER : COMPUTER_MARKER
  brd[square] = marker
end

def place_piece!(board, current_player)
  case current_player
  when 'Player' then player_places_piece!(board)
  when 'Computer' then computer_minimaxes_move!(board)
  end
end

def board_full?(brd)
  empty_squares(brd).empty?
end

def someone_won?(brd)
  !!detect_winner(brd)
end

def detect_winner(brd)
  WINNING_LINES.each do |line|
    if brd.values_at(*line).count(PLAYER_MARKER) == 3
      return 'Player'
    elsif brd.values_at(*line).count(COMPUTER_MARKER) == 3
      return 'Computer'
    end
  end
  nil
end

def detect_winning_move(brd, player = 'Player')
  winning_move = 0
  winning_marker =  case player
                    when 'Player' then PLAYER_MARKER
                    when 'Computer' then COMPUTER_MARKER
                    end

  WINNING_LINES.each do |line|
    if brd.values_at(*line).count(winning_marker) == 2
      winning_move = line.select { |key| brd[key] != winning_marker }[0]
      return winning_move if brd[winning_move] == INITIAL_MARKER
    end
  end
  nil
end

# rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
def minimax(brd, player = 'Computer')
  case detect_winner(brd)
  when 'Player' then return [-Float::INFINITY, nil]
  when 'Computer' then return [Float::INFINITY, nil]
  end

  return [0, nil] if board_full?(brd)

  case player
  when 'Computer'
    value = -Float::INFINITY
    possible_moves = empty_squares(brd)
    best_move = nil

    possible_moves.each do |move|
      new_brd = brd.dup
      algo_places_piece!(new_brd, move, player)
      new_value, = minimax(new_brd, 'Player')

      if new_value > value
        best_move = move
        value = new_value
      end
    end

    [value, best_move]

  when 'Player'
    value = Float::INFINITY
    possible_moves = empty_squares(brd)
    best_move = nil

    possible_moves.each do |move|
      new_brd = brd.dup
      algo_places_piece!(new_brd, move, player)
      new_value, = minimax(new_brd, 'Computer')

      if new_value < value
        best_move = move
        value = new_value
      end
    end

    [value, best_move]
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize

score = initialize_score

loop do
  board = initialize_board
  current_player = choose_first_player

  loop do
    display_board(board)
    place_piece!(board, current_player)
    break if someone_won?(board) || board_full?(board)
    current_player = alternate_player(current_player)
  end

  display_board(board)
  winner = detect_winner(board)

  if someone_won?(board)
    prompt "#{winner} won!"
    score[winner.to_sym] += 1

    if score[winner.to_sym] >= 5
      prompt("#{winner} has won 5 games. This end the match.")
      break
    end
  else
    prompt "It's a tie!"
  end

  prompt "Play again? (y or n)"
  answer = gets.chomp
  break unless answer.downcase.start_with?('y')
end

prompt "Thanks for paying Tic-Tac-Toe. Goodbye!"
