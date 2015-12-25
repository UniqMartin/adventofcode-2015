# Advent of Code 2015 - Day 14

def read_input
  File.read(File.expand_path("../input.txt", __FILE__))
end

def cumsum(array)
  partial = 0
  array.map { |element| partial += element }
end

class Reindeer
  attr_reader :name
  attr_reader :speed
  attr_reader :race_time
  attr_reader :rest_time

  def initialize(name, speed, race_time, rest_time)
    @name = name
    @speed = speed
    @race_time = race_time
    @rest_time = rest_time
  end

  def distance_after(target_time)
    distance_history(target_time).last
  end

  def distance_history(target_time)
    lap_time = race_time + rest_time
    num_laps = (target_time + lap_time - 1) / lap_time
    history = single_lap_history * num_laps
    cumsum(history[0...target_time])
  end

  private

  def single_lap_history
    [speed] * race_time + [0] * rest_time
  end
end

class ReindeerRace
  REINDEER_REGEXP =
    %r{^(.+) can fly (\d+) km/s for (\d+) seconds, but then must rest for (\d+) seconds\.$} # rubocop:disable Metrics/LineLength

  attr_reader :reindeer

  def initialize
    @reindeer = []
  end

  def add_reindeer(line)
    name, speed, race_time, rest_time = line.match(REINDEER_REGEXP)[1..4]
    reindeer << Reindeer.new(name, speed.to_i, race_time.to_i, rest_time.to_i)
  end

  def winning_distance_after(target_time)
    reindeer.map { |deer| deer.distance_after(target_time) }.max
  end

  def winning_points_after(target_time)
    points = Array.new(reindeer.size) { 0 }
    dists = reindeer.map { |deer| deer.distance_history(target_time) }.transpose
    dists.each do |dist|
      max_dist = dist.max
      dist.each_with_index { |d, i| points[i] += 1 if d == max_dist }
    end
    points.max
  end
end

def main
  race = ReindeerRace.new

  lines = read_input.split("\n").reject(&:empty?)
  lines.each { |line| race.add_reindeer(line) }

  puts "Part One: #{race.winning_distance_after(2503)}"
  puts "Part Two: #{race.winning_points_after(2503)}"
end

main if "main" == to_s
