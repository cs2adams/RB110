# only_even.rb

number = 0

until number == 10
  number += 1
  next if number.odd? || number <= 0
  puts number
end