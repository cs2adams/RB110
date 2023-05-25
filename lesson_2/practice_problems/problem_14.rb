# problem_14.rb

hsh = {
  'grape' => {type: 'fruit', colors: ['red', 'green'], size: 'small'},
  'carrot' => {type: 'vegetable', colors: ['orange'], size: 'medium'},
  'apple' => {type: 'fruit', colors: ['red', 'green'], size: 'medium'},
  'apricot' => {type: 'fruit', colors: ['orange'], size: 'medium'},
  'marrow' => {type: 'vegetable', colors: ['green'], size: 'large'},
}

data = hsh.each_with_object([]) do |(_, info), arr|
  arr <<  if info[:type] == 'fruit'
            info[:colors].map { |col| col.capitalize }
          else
            info[:size].upcase
          end
end

p data
