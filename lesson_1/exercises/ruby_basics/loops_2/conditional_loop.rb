# conditional_loop.rb

process_the_loop = [true, false].sample

while process_the_loop
  puts "The loop was processed"
  break
end

puts "The loop wasn't processed!" unless process_the_loop