# problem_8.rb

hsh = {first: ['the', 'quick'], second: ['brown', 'fox'], third: ['jumped'], fourth: ['over', 'the', 'lazy', 'dog']}

hsh.each do |_, v|
  v.each do |word|
    word.chars.each do |char|
      puts char if %w(a e i o u).include?(char)
    end
  end
end