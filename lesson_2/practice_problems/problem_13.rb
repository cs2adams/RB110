# problem_13.rb

arr = [[1, 6, 9], [6, 1, 7], [1, 8, 3], [1, 5, 9]]

new_arr = arr.sort_by do |sub_arr|
  sub_arr.reject { |num| num % 2 == 0 }
end

p new_arr