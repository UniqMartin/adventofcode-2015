# Advent of Code 2015 - Day 10

INPUT_DIGITS = "3113322113".freeze

def expand_once(digits)
  digits.chars.chunk { |e| e }.map { |e, l| "#{l.length}#{e}" }.join
end

def expand(digits, rounds)
  result = digits
  rounds.times do
    result = expand_once(result)
  end
  result
end

def main
  digits_40 = expand(INPUT_DIGITS, 40) # 40 rounds
  digits_50 = expand(digits_40, 10) # 50 rounds (or 10 additional rounds)
  length_40 = digits_40.length
  length_50 = digits_50.length

  puts "Part One: #{length_40}"
  puts "Part Two: #{length_50}"
end

main if "main" == to_s
