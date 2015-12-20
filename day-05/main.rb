# Advent of Code 2015 - Day 5

def read_input
  File.read(File.expand_path("../input.txt", __FILE__))
end

module RulesOne
  RULE_1 = /([aeiou].*){3,}/ # at least three vowels
  RULE_2 = /(.)\1/ # at least one letter twice in a row
  RULE_3 = /(ab|cd|pq|xy)/ # none of these

  def self.nice?(word)
    word[RULE_1] && word[RULE_2] && !word[RULE_3]
  end
end

module RulesTwo
  RULE_1 = /(..).*\1/ # two consecutive letters at least twice (no overlap)
  RULE_2 = /(.).\1/ # repeated letter with exactly one letter between

  def self.nice?(word)
    word[RULE_1] && word[RULE_2]
  end
end

def main
  words = read_input.split("\n").reject(&:empty?)

  nice_words_one = words.select { |word| RulesOne.nice?(word) }
  nice_words_two = words.select { |word| RulesTwo.nice?(word) }

  puts "Part One: #{nice_words_one.length}"
  puts "Part Two: #{nice_words_two.length}"
end

main if "main" == to_s
