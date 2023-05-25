# problem_10.rb

arr = [{a: 1}, {b: 2, c: 3}, {d: 4, e: 5, f: 6}]

new_arr = arr.map do |old_hash|
  new_hash = Hash.new
  old_hash.each do |k, v|
    new_hash[k] = v + 1
  end
  new_hash
end

p new_arr