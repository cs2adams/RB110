# twenty_one.rb
require 'pry'
require 'pry-byebug'

SUITS = ['Spades', 'Clubs', 'Hearts', 'Diamonds']
FACES = [
  { name: 'Jack', value: 10 }, { name: 'Queen', value: 10 },
  { name: 'King', value: 10 }, { name: 'Ace', value: 11 }
]
MAX_SCORE = 21
DEALER_HIT_THRESHOLD = 17

def initialize_deck
  deck = []

  SUITS.each do |suit|
    2.upto(10) do |num|
      deck << { name: num.to_s, value: num, suit: suit }
    end

    FACES.each do |face|
      deck << { name: face[:name], value: face[:value], suit: suit }
    end
  end
  deck
end

def initialize_players
  player = {
    name: 'You', hand: [], hand_value: 0, score: 0,
    possessive: 'have', plural: '', busted: false
  }
  dealer = {
    name: 'Dealer', hand: [], hand_value: 0, score: 0,
    possessive: 'has', plural: 's', busted: false
  }
  [player, dealer]
end

def reset(players)
  players.each { |player| player[:busted] = false }
end

def shuffle!(deck, players)
  players.each do |player|
    hand = player[:hand]
    hand.size.times { deck << hand.pop }
  end

  indices = 0.upto(deck.size - 1).to_a
  deck.sort_by! { |_| indices.delete_at(rand(indices.size)) }
end

def deal!(player, deck, num_cards)
  num_cards.times { player[:hand] << deck.pop }
  player[:hand_value] = total_hand_value(player)
end

def total_hand_value(player)
  player_cards = player[:hand]
  hand_value = player_cards.inject(0) { |total, card| total + card[:value] }

  num_aces = player_cards.count { |card| card[:name] == 'Ace' }
  num_aces.times { hand_value -= 10 if hand_value > MAX_SCORE }

  hand_value
end

def hand_size(player)
  player[:hand].size
end

def card_string(cards, num_cards)
  if num_cards == 1
    cards.join
  elsif num_cards == 2
    cards.join(' and ')
  elsif num_cards > 2
    cards[-1] = cards[-1].chars.unshift('and ').join
    cards.join(', ')
  end
end

def show(player, num_cards)
  print "#{player[:name]} #{player[:possessive]}: "
  cards = player[:hand][0..num_cards - 1]
  cards.map! { |card| "#{card[:name]} of #{card[:suit]}" }

  card_string = card_string(cards, num_cards)

  puts card_string
end

def prompt_choice(valid_choices)
  player_choice = ''

  loop do
    player_choice = gets.chomp
    break if valid_choice?(player_choice, valid_choices)
    puts "Input not recognized. Please try again."
  end

  player_choice
end

def valid_choice?(choice, valid_choices)
  !choice.empty? && valid_choices.include?(choice[0].downcase)
end

def player_choose_action
  puts "Would you like to hit or stay? ('hit'/'stay')"
  prompt_choice(['h', 's'])
end

def dealer_choose_action(dealer)
  dealer[:hand_value] < DEALER_HIT_THRESHOLD ? 'h' : 's'
end

def choose_action(player)
  case player[:name]
  when 'You' then player_choose_action
  when 'Dealer' then dealer_choose_action(player)
  end
end

def hit!(player, deck)
  deal!(player, deck, 1)
end

def stay(player)
  puts "#{player[:name]} stay#{player[:plural]}"
end

def player_busts?(player)
  player[:hand_value] > MAX_SCORE
end

def other_player(players, player)
  players.select { |p| p != player }[0]
end

def player_turn!(player, deck)
  show(player, hand_size(player))

  if player_busts?(player)
    player[:busted] = true
    puts "#{player[:name]} bust#{player[:plural]}."
    return
  end

  player_choice = choose_action(player)

  if player_choice[0].downcase == 'h'
    puts "#{player[:name]} choose#{player[:plural]} to hit."
    hit!(player, deck)
    return player_turn!(player, deck)
  end

  stay(player)
end

def scores_equal?(players)
  players[0][:hand_value] == players[1][:hand_value]
end

def determine_winner(players)
  players.each do |player|
    return other_player(players, player) if player[:busted]
  end

  return players if scores_equal?(players)

  players_sorted = players.sort_by { |player| player[:hand_value] }
  players_sorted[-1]
end

def display_winner(winner, players)
  if winner == players
    return puts "It's a tie!"
  end

  loser = other_player(players, winner)
  if loser[:busted]
    puts "#{winner[:name]} win#{winner[:plural]}"
  else
    puts "#{winner[:name]} win#{winner[:plural]} " \
    "with #{winner[:hand_value]}."
  end
end

def update_score!(winner, players)
  return if winner == players
  winner[:score] += 1
end

def play_again?
  puts 'Would you like to play again? (y/n)'
  prompt_choice(['y', 'n'])[0].downcase == 'y'
end

player, dealer = initialize_players
players = [player, dealer]
deck = initialize_deck

loop do
  system('clear')
  reset(players)
  shuffle!(deck, players)

  players.each { |current_player| deal!(current_player, deck, 2) }
  show(dealer, 1)

  players.each do |current_player|
    player_turn!(current_player, deck)
    break if current_player[:busted]
  end

  winner = determine_winner(players)
  display_winner(winner, players)

  update_score!(winner, players)

  if winner != players && winner[:score] == 5
    puts "#{winner[:name]} has won 5 rounds. This ends the game."
    break
  end

  break unless play_again?
end

puts 'Thank you for playing. Goodbye!'
