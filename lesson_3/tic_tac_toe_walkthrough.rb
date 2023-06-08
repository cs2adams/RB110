# tic_tac_toe_walkthrough.rb
require 'pry'
require 'pry-byebug'

INITIAL_MARKER = ' '
MAX_ALGORITHM_ITERATIONS = 1_000_000
LETTERS = ('A'..'Z').to_a

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

def choose_first_player(players)
  human_players = players.select { |player| player[:type] == 'human' }
  remaining_players = players.dup

  human_players.each do |player|
    return player if remaining_players.size == 1

    prompt "#{player[:name]}, would you like to go first? " \
      "Please enter 'y' for yes, 'n' for no"
    player_choice = gets.chomp
    return player if player_choice.downcase[0] == 'y'
    remaining_players.delete(player)
  end
  remaining_players.sample
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
def display_board(brd, board_width, player)
  system('clear')
  if player[:type] == 'human'
    puts "You are #{player[:name]}. Your marker is #{player[:marker]}."
  end

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

def initialize_score(players)
  score = Hash.new

  players.each do |player|
    score[player[:name].to_sym] = 0
  end

  score
end

def max_allowable_players(board_width)
  board_width / 2 + board_width % 2
end

def valid_integer?(str)
  str.chars.all? { |char| char.match(/[0-9]/) }
end

def get_player_name(players, num)
  name = ''
  prompt "Hello, Player #{num}. Please enter your name:"

  loop do
    name = gets.chomp
    taken_names = players.each_with_object([]) { |p, arr| arr << p[:name] }

    if name.empty?
      prompt 'No name was given. Please try again.'
    elsif taken_names.include?(name)
      prompt 'That name is already taken. Please enter a different name.'
    else
      break
    end
  end
  prompt "Welcome to the game, #{name}."

  name
end

def get_current_markers(players)
  current_markers = []

  players.each do |player|
    current_markers << player[:marker]
  end

  current_markers
end

def next_marker(current_markers)
  if !current_markers.include?('X')
    'X'
  elsif !current_markers.include?('O')
    'O'
  else
    LETTERS.select { |letter| !current_markers.include?(letter) }.sample
  end
end

def add_human_player!(players, num)
  name = get_player_name(players, num)
  current_player_hash = Hash.new
  current_markers = get_current_markers(players)
  marker = next_marker(current_markers)

  current_player_hash[:name] = name
  current_player_hash[:type] = 'human'
  current_player_hash[:marker] = marker

  players << current_player_hash
end

def add_computer_player!(players, num)
  name = 'Computer' + num.to_s
  current_player_hash = Hash.new
  current_markers = get_current_markers(players)
  marker = next_marker(current_markers)

  current_player_hash[:name] = name
  current_player_hash[:type] = 'computer'
  current_player_hash[:marker] = marker

  players << current_player_hash
end

def get_num_humans(max_players)
  prompt 'Based on the selected board size, the game can ' \
    "accommodate up to #{max_players} players."
  prompt 'The players can be any combination of humans and computers.'
  prompt 'How many human players will be playing?'

  num_humans = ''

  loop do
    num_humans = gets.chomp
    if valid_integer?(num_humans) && num_humans.to_i <= max_players
      num_humans = num_humans.to_i
      break
    end
    prompt 'Response not valid. Please enter an integer ' \
      "between 0 and #{max_players}."
  end
  num_humans
end

def get_num_computers(min_computers, max_computers)
  return min_computers if min_computers == max_computers

  prompt 'How many AI opponents would you like in the game?'
  num_computers = 0

  loop do
    num_computers = gets.chomp

    if valid_integer?(num_computers) && num_computers.to_i >= min_computers &&
       num_computers.to_i <= max_computers
      num_computers = num_computers.to_i
      break
    end

    prompt 'Response not valid. Please enter an integer ' \
      "between #{min_computers} and #{max_computers}"
  end
  num_computers
end

def create_player_array(num_humans, num_computers)
  players = []
  1.upto(num_humans) { |num| add_human_player!(players, num) }
  1.upto(num_computers) { |num| add_computer_player!(players, num) }
  players
end

def prompt_no_humans
  prompt 'You have selected a game with no human players.'
  prompt 'You will be a passive observer' \
    'of your AI overlords.'
  prompt 'The computers are duking it out...'
end

def prompt_no_computers(board_width, num_humans)
  prompt "You have selected a game with #{num_humans} human players."
  prompt 'This is the maximum allowable number of players for a ' \
    "#{board_width} x #{board_width} board."
  prompt 'There will be no AI opponents in this game.'
end

def initialize_players(board_width)
  max_players = max_allowable_players(board_width)
  num_humans = get_num_humans(max_players)

  min_computers = if num_humans == 0
                    prompt_no_humans
                    2
                  elsif num_humans == 1
                    1
                  else
                    0
                  end

  max_computers = max_players - num_humans
  num_computers = get_num_computers(min_computers, max_computers)
  prompt_no_computers(board_width, num_humans) if num_computers == 0

  create_player_array(num_humans, num_computers)
end

def empty_squares(brd)
  brd.keys.select { |num| brd[num] == INITIAL_MARKER }
end

def get_next_player(players, current_player)
  next_player_index = nil

  players.each_with_index do |player, idx|
    if player == current_player
      next_player_index = idx + 1
      break
    end
  end

  if next_player_index == players.size
    next_player_index = 0
  end

  players[next_player_index]
end

def human_places_piece!(brd, current_player)
  square = ''
  loop do
    prompt "Choose a square (#{joinor(empty_squares(brd))}):"
    square = gets.chomp.to_i
    break if empty_squares(brd).include?(square)
    prompt "Sorry, that's not a valid choice."
  end

  brd[square] = current_player[:marker]
end

# rubocop:disable Metrics/ParameterLists
def computer_places_piece!(brd, board_width, winning_lines, max_algo_depth,
                           players, current_player)
  _, square = minimax(brd, board_width, winning_lines, max_algo_depth,
                      players, current_player, current_player)
  brd[square] = brd[square] = current_player[:marker]
end

def algo_places_piece!(brd, square, player)
  brd[square] = player[:marker]
end

def place_piece!(board, board_width, winning_lines,
                 max_algo_depth, players, current_player)
  case current_player[:type]
  when 'human'
    human_places_piece!(board, current_player)
  when 'computer'
    computer_places_piece!(board, board_width, winning_lines, max_algo_depth,
                           players, current_player)
  end
end
# rubocop:enable Metrics/ParameterLists

def board_full?(brd)
  empty_squares(brd).empty?
end

def someone_won?(brd, board_width, winning_lines, players)
  !!detect_winner(brd, board_width, winning_lines, players)
end

def detect_winner(brd, board_width, winning_lines, players)
  winning_lines.each do |line|
    players.each do |player|
      if brd.values_at(*line).count(player[:marker]) == board_width
        return player[:name]
      end
    end
  end
  nil
end

def get_other_player_markers(players, current_player)
  other_player_markers = []
  other_players = players.select { |player| player != current_player }

  other_players.each do |player|
    other_player_markers << player[:marker]
  end

  other_player_markers
end

def get_num_winning_lines(brd, winning_lines, move, players, current_player)
  num = 0
  other_player_markers = get_other_player_markers(players, current_player)

  winning_lines.each do |line|
    if line.include?(move) &&
       !brd.values_at(*line).any? do |marker|
         other_player_markers.include?(marker)
       end
      num += 1
    end
  end
  num
end

def heuristic_square_value(brd, winning_lines, square, players, current_player)
  num_winning_lines = get_num_winning_lines(brd, winning_lines, square,
                                            players, current_player)

  case num_winning_lines
  when 4 then 10000
  when 3 then 1000
  when 2 then 100
  when 1 then 10
  else        0
  end
end

def heuristic_board_value(brd, winning_lines, players,
                          current_player, minimaxing_player)
  possible_moves = empty_squares(brd)
  best_move = nil
  value = 0

  possible_moves.each do |move|
    current_value = heuristic_square_value(brd, winning_lines, move, players,
                                           current_player)

    if current_value > value
      best_move = move
      value = current_value
    end
  end
  value *= -1 if current_player != minimaxing_player

  [value, best_move]
end

# rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/ParameterLists
def minimax(brd, board_width, winning_lines,
            max_algo_depth, players, current_player,
            minimaxing_player, depth = 0)
  winner = detect_winner(brd, board_width, winning_lines, players)
  if winner == minimaxing_player[:name]
    return [Float::INFINITY, nil]
  elsif !winner.nil?
    return [-Float::INFINITY, nil]
  end

  return [0, nil] if board_full?(brd)

  if depth == max_algo_depth
    return heuristic_board_value(brd, winning_lines, players,
                                 current_player, minimaxing_player)
  end

  value = Float::INFINITY
  possible_moves = empty_squares(brd)
  best_move = nil
  next_player = get_next_player(players, current_player)

  case current_player
  when minimaxing_player
    value = -value
    possible_moves.each do |move|
      new_brd = brd.dup
      algo_places_piece!(new_brd, move, current_player)
      new_value, = minimax(new_brd, board_width, winning_lines,
                           max_algo_depth, players, next_player,
                           minimaxing_player, depth + 1)

      if new_value >= value
        best_move = move
        value = new_value
      end
    end
  else
    possible_moves.each do |move|
      new_brd = brd.dup
      algo_places_piece!(new_brd, move, current_player)
      new_value, = minimax(new_brd, board_width, winning_lines,
                           max_algo_depth, players, next_player,
                           minimaxing_player, depth + 1)

      if new_value <= value
        best_move = move
        value = new_value
      end
    end
  end
  [value, best_move]
end
# rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/ParameterLists

board_width = set_board_width
winning_lines = get_winning_lines(board_width)
max_algo_depth = get_max_algorithm_depth(board_width)
players = initialize_players(board_width)
score = initialize_score(players)

loop do
  board = initialize_board(board_width)
  current_player = choose_first_player(players)

  loop do
    if current_player[:type] == 'human'
      display_board(board, board_width, current_player)
    end

    place_piece!(board, board_width, winning_lines,
                 max_algo_depth, players, current_player)

    if someone_won?(board, board_width, winning_lines, players) ||
       board_full?(board)
      break
    end
    current_player = get_next_player(players, current_player)
  end

  display_board(board, board_width, current_player)
  winner = detect_winner(board, board_width, winning_lines, players)

  if someone_won?(board, board_width, winning_lines, players)
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
