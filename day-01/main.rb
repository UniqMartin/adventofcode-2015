# Advent of Code 2015 - Day 1

def read_input
  File.read(File.expand_path("../input.txt", __FILE__))
end

def main
  input = read_input.tr("^()", "") # limit to valid characters

  basement = nil
  floor = 0

  input.each_char.each_with_index do |char, index|
    floor += (char == "(") ? +1 : -1
    basement = index + 1 if floor == -1 && !basement
  end

  puts "Part One: #{floor}" # final floor
  puts "Part Two: #{basement}" # index of first basement entry
end

main if "main" == to_s
