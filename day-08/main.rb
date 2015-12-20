# Advent of Code 2015 - Day 8

def read_input
  File.read(File.expand_path("../input.txt", __FILE__))
end

def decode_string(str)
  str[1..-2].gsub(/\\(\\|"|x\h{2})/, "*")
end

def encode_string(str)
  %(") + str.gsub(/("|\\)/, %(\\\1)) + %(")
end

def size_strings(ary)
  ary.map(&:length).reduce(0, :+)
end

def main
  lines = read_input.split("\n").reject(&:empty?)

  size_code = size_strings(lines)
  size_decoded = size_strings(lines.map { |str| decode_string(str) })
  size_encoded = size_strings(lines.map { |str| encode_string(str) })

  puts "Part One: #{size_code - size_decoded}"
  puts "Part Two: #{size_encoded - size_code}"
end

main if "main" == to_s
