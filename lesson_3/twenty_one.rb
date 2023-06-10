# twenty_one.rb

# Deck: An array of hashes
# Card: A hash with keys: name, value, suit
# for ace: value = 1
#   separate ace_vlaue mehtod to add 10 if needed

# shufle with sort_by

require 'pry'
require 'pry-byebug'
SUITS = ['Spades', 'Clubs', 'Hearts', 'Diamonds']
FACES = [
  { name: 'Jack', value: 10 }, { name: 'Queen', value: 10 },
  { name: 'King', value: 10 }, { name: 'Ace', value: 11 }
]

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
    name: 'You', hand: [], possessive: 'have', plural: '', busted: false
  }
  dealer = {
    name: 'Dealer', hand: [], possessive: 'has', plural: 's', busted: false
  }
  [player, dealer]
end

def print_deck(deck)
  deck.each do |card|
    puts card[:name] + ' of ' + card[:suit]
  end
end

def shuffle!(deck)
  indices = 0.upto(deck.size - 1).to_a

  deck.sort_by! { |_| indices.delete_at(rand(indices.size)) }
end

def deal!(player, deck, num_cards)
  num_cards.times { player[:hand] << deck.pop }
end

def total_hand_value(player)
  player_cards = player[:hand]
  hand_value = player_cards.inject(0) { |total, card| total + card[:value] }

  num_aces = player_cards.count { |card| card[:name] == 'Ace' }
  num_aces.times { hand_value -= 10 if hand_value > 21 }

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

def player_choose_action
  puts "Would you like to hit or stay? ('hit'/'stay')"
  player_choice = ''

  loop do
    player_choice = gets.chomp
    unless player_choice == ''
      break if ['h', 's'].include?(player_choice[0].downcase)
    end
    puts "Input not recognized. Please enter 'hit' or 'stay'."
  end

  player_choice
end

def dealer_choose_action(dealer)
  hand_value = total_hand_value(dealer)
  hand_value < 17 ? 'h' : 's'
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
  total_hand_value(player) > 21
end

def nobody_busted?(players)
  players.none? { |p| p[:busted] }
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

  if player_choice == 'h'
    puts "#{player[:name]} choose#{player[:plural]} to hit."
    hit!(player, deck)
    return player_turn!(player, deck)
  end

  stay(player)
end

def scores_equal(scores)
  scores[0][:score] == scores[1][:score]
end

def determine_winner(players)
  scores = players.map do |p|
    { player: p, score: total_hand_value(p) }
  end

  return players if scores_equal(scores)

  scores.sort_by! { |score| score[:score] }
  scores[-1][:player]
end

system('clear')
deck = initialize_deck
shuffle!(deck)

player, dealer = initialize_players
players = [player, dealer]

players.each { |current_player| deal!(current_player, deck, 2) }

show(dealer, 1)

players.each do |current_player|
  player_turn!(current_player, deck)
  if current_player[:busted]
    other_player = other_player(players, current_player)
    puts "#{other_player[:name]} win#{other_player[:plural]}"
    break
  end
end

if nobody_busted?(players)
  winner = determine_winner(players)

  if winner == players
    puts "It's a tie!"
  else
    puts "#{winner[:name]} win#{winner[:plural]} " \
      "with #{total_hand_value(winner)}."
  end
end
