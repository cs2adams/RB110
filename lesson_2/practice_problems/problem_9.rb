# problem_9.rb

arr = [['b', 'c', 'a'], [2, 1, 3], ['blue', 'black', 'green']]

arr2 = arr.map do |arr1|
  arr1.sort { |a, b| b <=> a }
end

p arr2