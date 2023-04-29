# problem_7.rb

statement = "The Flintstones Rock"
statement_array = statement.split('')
letters = statement_array.uniq

letter_hash = letters.each_with_object({}) do |letter, hash|
  hash[letter] = statement_array.count(letter)
end

p letter_hash