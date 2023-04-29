# problem_9.rb

def titleize(string)
  words = string.split
  words.map { |word| word.capitalize }.join(' ')
end

words = "the flintstones rock"
puts titleize(words)