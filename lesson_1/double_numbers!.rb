# double_numbers!.rb

def double_numbers!(numbers)
  counter = 0

  loop do
    break if counter == numbers.size

    current_number = numbers[counter]
    numbers[counter] = current_number * 2

    counter += 1
  end

  numbers
end

numbers = [1, 2, 3, 4, 5]

puts double_numbers!(numbers)
puts numbers