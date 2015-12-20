# Advent of Code 2015 - Day 9

def read_input
  File.read(File.expand_path("../input.txt", __FILE__))
end

class Map
  attr_reader :cities
  attr_reader :routes

  def initialize
    @cities = []
    @routes = []
  end

  def add_route(line)
    source, target, dist = line.match(/^(.+) to (.+) = (\d+)$/)[1..3]
    source_index = city_index(source)
    target_index = city_index(target)
    dist = dist.to_i

    add_edge(source_index, target_index, dist)
    add_edge(target_index, source_index, dist)
  end

  def find_longest
    find_route(:max)
  end

  def find_shortest
    find_route(:min)
  end

  private

  def add_edge(source, target, dist)
    routes[source] ||= []
    routes[source][target] = dist
  end

  def city_index(city_name)
    cities.index(city_name) || (cities.push(city_name).length - 1)
  end

  def normalize_routes
    return unless @normalized
    @normalized = true

    upper_bound = cities.length - 1
    (0..upper_bound).each do |index|
      routes[index] ||= []
      routes[index][upper_bound] ||= nil
    end
  end

  def find_route(selector)
    normalize_routes

    targets = (0...cities.length).to_a
    walk(selector, nil, targets)
  end

  def walk(selector, source, targets)
    return 0 if targets.empty?

    hops = source ? routes[source] : []
    targets.map do |target|
      (hops[target] || 0) + walk(selector, target, targets - [target])
    end.send(selector)
  end
end

def main
  map = Map.new

  lines = read_input.split("\n").reject(&:empty?)
  lines.each { |line| map.add_route(line) }

  puts "Part One: #{map.find_shortest}"
  puts "Part Two: #{map.find_longest}"
end

main if "main" == to_s
