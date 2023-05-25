# problem_16.rb

require 'securerandom'

def uuid()
  new_hex = SecureRandom.hex
  # breaks = []
  # until breaks.size >= 4
  #   new_break = rand(31)
  #   breaks << new_break unless breaks.include?(new_break)
  # end
  breaks = [7,11,15,19]

  breaks.sort!

  output = ''
  idx = 0
  while breaks.size > 0
    new_idx = breaks.shift
    output << new_hex[idx..new_idx] << '-'
    idx = new_idx + 1
  end
  output << new_hex[idx..-1]
end

p uuid