# problem_10.rb

def life_stage(age)
  if age < 17
    'kid'
  elsif age < 65
    'adult'
  elsif age >= 65
    'senior'
  end
end

munsters = {
  "Herman" => { "age" => 32, "gender" => "male" },
  "Lily" => { "age" => 30, "gender" => "female" },
  "Grandpa" => { "age" => 402, "gender" => "male" },
  "Eddie" => { "age" => 10, "gender" => "male" },
  "Marilyn" => { "age" => 23, "gender" => "female"}
}

munsters.each do |_, hash|
  hash['age_group'] = life_stage(hash['age'])
end

puts munsters