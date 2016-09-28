# Advent of Code 2015 - Day 3

require "set"

def read_input
  File.read(File.expand_path("../input.txt", __FILE__))
end

module SelectWithIndexExtension
  def select_with_index
    each_with_index.select { |_item, index| yield index }.map(&:first)
  end
end

def walk(instructions)
  x = 0
  y = 0
  trail = [[x, y]].to_set

  instructions.each do |char|
    case char
    when "^" then y -= 1
    when "v" then y += 1
    when "<" then x -= 1
    when ">" then x += 1
    end
    trail << [x, y]
  end

  trail
end

def walk_with_robo_santa(instructions)
  instructions_real_santa = instructions.select_with_index(&:even?)
  instructions_robo_santa = instructions.select_with_index(&:odd?)

  walk(instructions_real_santa) | walk(instructions_robo_santa)
end

def main
  instructions = read_input.tr("^\\^v><", "").chars # limit to valid characters
  instructions.extend(SelectWithIndexExtension)

  part_one = walk(instructions).count
  part_two = walk_with_robo_santa(instructions).count

  puts "Part One: #{part_one}" # unique houses visited (solo route)
  puts "Part Two: #{part_two}" # unique houses visited (with Robo-Santa)
end

main if "main" == to_s
