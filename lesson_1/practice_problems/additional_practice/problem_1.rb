# problem_1.rb

flintstones = ["Fred", "Barney", "Wilma", "Betty", "Pebbles", "BamBam"]

flint_hash = Hash.new

flintstones.each_with_index { |person, index|  flint_hash[person] = index }

puts flint_hash