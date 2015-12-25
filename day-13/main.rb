# Advent of Code 2015 - Day 13

def read_input
  File.read(File.expand_path("../input.txt", __FILE__))
end

class AmityMap
  SEATING_REGEXP =
    /^(.+) would (gain|lose) (\d+) happiness units by sitting next to (.+)\.$/

  attr_reader :names
  attr_reader :amity

  def initialize
    @names = []
    @amity = []
  end

  def add_amity(line)
    foo, sign, happiness, bar = line.match(SEATING_REGEXP)[1..4]
    foo_index = name_index(foo)
    bar_index = name_index(bar)
    happiness = happiness.to_i * ((sign == "gain") ? +1 : -1)

    add_pair(foo_index, bar_index, happiness)
  end

  def add_self
    @normalized = false
    self_index = name_index("Self")
    (0...self_index).each do |other_index|
      add_pair(self_index, other_index, 0)
      add_pair(other_index, self_index, 0)
    end

    self
  end

  def max_happiness
    normalize_amity

    all_happiness = []
    each_perm_of_pairs do |pairs|
      all_happiness << pairs.map do |foo, bar|
        amity[foo][bar] + amity[bar][foo]
      end.reduce(0, :+)
    end
    all_happiness.max
  end

  private

  def add_pair(foo, bar, happiness)
    amity[foo] ||= []
    amity[foo][bar] = happiness
  end

  def each_perm_of_pairs
    upper_bound = names.length - 1
    (0..upper_bound).to_a.permutation do |perm|
      pairs = perm.each_cons(2).to_a + [[perm.last, perm.first]]
      yield pairs
    end
  end

  def name_index(name)
    names.index(name) || (names.push(name).length - 1)
  end

  def normalize_amity
    return unless @normalized
    @normalized = true

    upper_bound = names.length - 1
    (0..upper_bound).each do |index|
      amity[index] ||= []
      (0..upper_bound).each do |second_index|
        amity[index][second_index] ||= 0
      end
    end
  end
end

def main
  map = AmityMap.new

  lines = read_input.split("\n").reject(&:empty?)
  lines.each { |line| map.add_amity(line) }

  puts "Part One: #{map.max_happiness}"
  puts "Part Two: #{map.add_self.max_happiness}"
end

main if "main" == to_s
