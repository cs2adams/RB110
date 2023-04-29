# problem_5.rb

flintstones = %w(Fred Barney Wilma Betty BamBam Pebbles)

indices = []
flintstones.each_with_index { |name, ind| indices << ind if name.slice(0,2) == 'Be' }
first_index = indices.first
puts first_index