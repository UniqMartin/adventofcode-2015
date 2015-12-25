# Advent of Code 2015 - Day 12

require "json"

def read_input
  File.read(File.expand_path("../input.json", __FILE__))
end

def recursive_sum(item)
  return 0 if item.is_a?(Hash) && item.value?("red")

  case item
  when Array
    item.map { |value| recursive_sum(value) }.reduce(0, :+)
  when Fixnum
    item
  when Hash
    item.map { |_key, value| recursive_sum(value) }.reduce(0, :+)
  else
    0
  end
end

def main
  json = read_input

  number_sum = json.scan(/[+-]?\d+/).map(&:to_i).reduce(0, :+)
  nonred_sum = recursive_sum(JSON.parse(json))

  puts "Part One: #{number_sum}"
  puts "Part Two: #{nonred_sum}"
end

main if "main" == to_s
