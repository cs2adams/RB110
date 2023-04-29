# problem_2.rb

ages = { "Herman" => 32, "Lily" => 30, "Grandpa" => 5843, "Eddie" => 10, "Marilyn" => 22, "Spot" => 237 }

sum_of_ages = ages.values.inject(:+)
puts sum_of_ages