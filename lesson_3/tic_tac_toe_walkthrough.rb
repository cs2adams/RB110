# tic_tac_toe_walkthrough.rb
require 'pry'
require 'pry-byebug'

INITIAL_MARKER = ' '
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'
PLAYERS = ['Player', 'Computer']
MAX_ALGORITHM_ITERATIONS = 1_000_000

def prompt(msg)
  puts "=> #{msg}"
end

def get_max_algorithm_depth(board_width)
  current_algo_depth = 0
  num_iterations = board_width**2 # Number of possible moves at start of game
  num_empty_squares = num_iterations

  loop do
    num_empty_squares -= 1
    num_iterations *= num_empty_squares unless num_empty_squares == 0

    break if num_iterations > MAX_ALGORITHM_ITERATIONS || num_empty_squares == 0
    current_algo_depth += 1
  end

  current_algo_depth
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

def set_board_width
  prompt('Please enter the desired width of the board (must be 3 or greater)')
  board_width = 0

  loop do
    board_width = gets.chomp.to_i
    break if board_width.to_s.to_i == board_width && board_width >= 3
    prompt "Not a valid width. Please try again."
  end
  board_width
end

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
def get_winning_lines(board_width)
  winning_rows = []
  winning_cols = []
  diagonals = [[], []]

  1.upto(board_width) do |i|
    current_row = []
    current_col = []

    diagonals[0] << board_width + (i - 1) * (board_width - 1)
    diagonals[1] << 1 + (i - 1) * (board_width + 1)

    1.upto(board_width) do |j|
      current_row << board_width * (i - 1) + j
      current_col << board_width * (j - 1) + i
    end

    winning_rows << current_row
    winning_cols << current_col
  end

  winning_rows + winning_cols + diagonals
end
# rubocop:enable Metrics/MethodLength, Metrics/AbcSize

# rubocop:disable Metrics/AbcSize, Metrics/MethodLength
def display_board(brd, board_width)
  system('clear')
  puts "You're a #{PLAYER_MARKER}. Computer is #{COMPUTER_MARKER}."

  current_square = 1
  while current_square < board_width**2
    puts "     |" * (board_width - 1)
    1.upto(board_width) do |idx|
      print "  #{brd[current_square]}  "

      case idx
      when board_width then puts
      else                  print '|'
      end
      current_square += 1
    end

    puts "     |" * (board_width - 1)
    unless current_square > board_width**2
      puts '-----+' * (board_width - 1) + '-----'
    end
  end
end
# rubocop:enable Metrics/AbcSize, Metrics/MethodLength

def initialize_board(board_width)
  new_board = {}
  (1..board_width**2).each { |num| new_board[num] = INITIAL_MARKER }
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

def computer_minimaxes_move!(brd, board_width, winning_lines, max_algo_depth)
  _, square = minimax(brd, board_width, winning_lines, max_algo_depth)
  brd[square] = COMPUTER_MARKER
end

def algo_places_piece!(brd, square, player)
  marker = player == 'Player' ? PLAYER_MARKER : COMPUTER_MARKER
  brd[square] = marker
end

def place_piece!(board, board_width, winning_lines,
                 max_algo_depth, current_player)
  case current_player
  when 'Player'
    player_places_piece!(board)
  when 'Computer'
    computer_minimaxes_move!(board, board_width, winning_lines, max_algo_depth)
  end
end

def board_full?(brd)
  empty_squares(brd).empty?
end

def someone_won?(brd, board_width, winning_lines)
  !!detect_winner(brd, board_width, winning_lines)
end

def detect_winner(brd, board_width, winning_lines)
  winning_lines.each do |line|
    if brd.values_at(*line).count(PLAYER_MARKER) == board_width
      return 'Player'
    elsif brd.values_at(*line).count(COMPUTER_MARKER) == board_width
      return 'Computer'
    end
  end
  nil
end

def get_num_winning_lines(brd, winning_lines, move, player)
  num = 0
  winning_lines.each do |line|
    if line.include?(move) &&
       !brd.values_at(*line).include?(alternate_player(player))
      num += 1
    end
  end
  num
end

def heuristic_square_value(brd, winning_lines, square, player)
  num_winning_lines = get_num_winning_lines(brd, winning_lines, square, player)

  case num_winning_lines
  when 4 then 10000
  when 3 then 1000
  when 2 then 100
  when 1 then 10
  else        0
  end
end

def heuristic_board_value(brd, winning_lines, player)
  possible_moves = empty_squares(brd)
  best_move = nil
  value = 0

  possible_moves.each do |move|
    current_value = heuristic_square_value(brd, winning_lines, move, player)

    if current_value > value
      best_move = move
      value = current_value
    end
  end
  value *= -1 if player == 'Player'

  [value, best_move]
end

# rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/ParameterLists
def minimax(brd, board_width, winning_lines,
            max_algo_depth, player = 'Computer', depth = 0)
  case detect_winner(brd, board_width, winning_lines)
  when 'Player' then return [-Float::INFINITY, nil]
  when 'Computer' then return [Float::INFINITY, nil]
  end

  return [0, nil] if board_full?(brd)
  if depth == max_algo_depth
    return heuristic_board_value(brd, winning_lines, player)
  end

  case player
  when 'Computer'
    value = -Float::INFINITY
    possible_moves = empty_squares(brd)
    best_move = nil

    possible_moves.each do |move|
      new_brd = brd.dup
      algo_places_piece!(new_brd, move, player)
      new_value, = minimax(new_brd, board_width, winning_lines,
                           max_algo_depth, 'Player', depth + 1)

      if new_value >= value
        best_move = move
        value = new_value
      end
    end

    if depth == 0
    end
    [value, best_move]

  when 'Player'
    value = Float::INFINITY
    possible_moves = empty_squares(brd)
    best_move = nil

    possible_moves.each do |move|
      new_brd = brd.dup
      algo_places_piece!(new_brd, move, player)
      new_value, = minimax(new_brd, board_width, winning_lines,
                           max_algo_depth, 'Computer', depth + 1)

      if new_value <= value
        best_move = move
        value = new_value
      end
    end

    [value, best_move]
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/ParameterLists

score = initialize_score
board_width = set_board_width
winning_lines = get_winning_lines(board_width)
max_algo_depth = get_max_algorithm_depth(board_width)
loop do
  board = initialize_board(board_width)
  current_player = choose_first_player

  loop do
    display_board(board, board_width)

    place_piece!(board, board_width, winning_lines,
                 max_algo_depth, current_player)

    if someone_won?(board, board_width, winning_lines) || board_full?(board)
      break
    end

    current_player = alternate_player(current_player)
  end

  display_board(board, board_width)
  winner = detect_winner(board, board_width, winning_lines)

  if someone_won?(board, board_width, winning_lines)
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
