# problem_12.rb

arr = [[:a, 1], ['b', 'two'], ['sea', {c: 3}], [{a: 1, b: 2, c: 3, d: 4}, 'D']]

hsh = arr.each_with_object({}) do |arr, hsh|
  hsh[arr[0]] = arr[1]
end

p hsh