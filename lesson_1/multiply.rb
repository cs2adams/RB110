# multiply.rb

def multiply(numbers, multiplier)
  new_numbers = []
  counter = 0

  loop do
    break if counter == numbers.size
    
    new_numbers << numbers[counter] * multiplier
    counter += 1
  end

  new_numbers
end

my_numbers = (1..6).to_a
puts multiply(my_numbers, 4)
puts my_numbers