# pick_fruit.rb

produce = {
  'apple' => 'Fruit',
  'carrot' => 'Vegetable',
  'pear' => 'Fruit',
  'broccoli' => 'Vegetable'
}

def select_fruit(produce)
  fruits = Hash.new
  produce_keys = produce.keys
  counter = 0

  loop do
    break if counter == produce_keys.size

    current_produce = produce_keys[counter]
    current_produce_type = produce[current_produce]
    fruits[current_produce] = current_produce_type if current_produce_type == 'Fruit'
    
    counter += 1    
  end

  fruits
end

puts select_fruit(produce) # => {"apple"=>"Fruit", "pear"=>"Fruit"}