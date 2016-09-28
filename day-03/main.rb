# Advent of Code 2015 - Day 3

def read_input
  File.read(File.expand_path("../input.txt", __FILE__))
end

module SelectWithIndexExtension
  def select_with_index
    each_with_index.select { |_item, index| yield index }.map(&:first)
  end
end

def walk(route)
  x = 0
  y = 0
  trail = [[x, y]]

  route.each do |char|
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

def walk_with_robo_santa(route)
  route_santa = route.select_with_index(&:even?)
  route_robo_santa = route.select_with_index(&:odd?)

  walk(route_santa) + walk(route_robo_santa)
end

def main
  input = read_input.tr("^\\^v><", "").chars # limit to valid characters
  input.extend(SelectWithIndexExtension)

  num_solo = walk(input).uniq.length
  num_with_robo = walk_with_robo_santa(input).uniq.length

  puts "Part One: #{num_solo}" # unique houses visited (solo route)
  puts "Part Two: #{num_with_robo}" # unique houses visited (with Robo-Santa)
end

main if "main" == to_s
