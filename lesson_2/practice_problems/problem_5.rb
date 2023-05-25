# problem_5.rb

munsters = {
  "Herman" => { "age" => 32, "gender" => "male" },
  "Lily" => { "age" => 30, "gender" => "female" },
  "Grandpa" => { "age" => 402, "gender" => "male" },
  "Eddie" => { "age" => 10, "gender" => "male" },
  "Marilyn" => { "age" => 23, "gender" => "female"}
}

total_age_males = 0
munsters.select { |_, v| v['gender'] == 'male' }.each do |_, v|
  total_age_males += v['age']
end
puts total_age_males