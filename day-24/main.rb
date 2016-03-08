# Advent of Code 2015 - Day 24

module Day24
  def self.read_input
    File.read(File.expand_path("../input.txt", __FILE__))
  end

  def self.shortest_subsets(weights, target_weight)
    list = []

    1.upto(weights.size).each do |choose|
      weights.combination(choose) do |subset|
        subset_weight = subset.reduce(0, :+)
        list << subset if subset_weight == target_weight
      end

      return list unless list.empty?
    end

    raise "Failed to find subsets with given target weight."
  end

  def self.minimize_qe(weights, num_parts)
    subset_weight = weights.reduce(0, :+) / num_parts
    subsets = shortest_subsets(weights, subset_weight)

    subsets.map { |subset| subset.reduce(1, :*) }.min
  end

  def self.main
    weights = read_input.split("\n").reject(&:empty?).map(&:to_i)

    puts "Part One: #{minimize_qe(weights, 3)}"
    puts "Part Two: #{minimize_qe(weights, 4)}"
  end
end

Day24.main if "main" == to_s
