# say_hello.rb

say_hello = true
num_times = 1
while say_hello
  puts 'Hello!'
  say_hello = false if num_times >= 5
  num_times += 1
end