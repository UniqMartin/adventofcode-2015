# Advent of Code 2015 - Day 16

class Aunt
  AUNT_REGEXP = /^Sue (\d+): (.*)$/
  INFO_REGEXP = /(\w+): (\d+)/

  attr_reader :number
  attr_reader :infos

  def self.from_line(line)
    number, infos = line.match(AUNT_REGEXP)[1..2]
    infos = Hash[infos.scan(INFO_REGEXP).map { |k, v| [k.to_sym, v.to_i] }]
    new(number, infos)
  end

  def initialize(number, infos)
    @number = number
    @infos = infos
  end

  def match?(wanted, relop = {})
    infos.each do |key, value|
      next unless wanted.key?(key)
      return false unless value_match?(value, wanted[key], relop[key])
    end
    true
  end

  private

  def value_match?(aunt_value, wanted_value, relop)
    case relop
    when :gt
      aunt_value > wanted_value
    when :lt
      aunt_value < wanted_value
    else
      aunt_value == wanted_value
    end
  end
end

module Day16
  WANTED = {
    :children    => 3,
    :cats        => 7,
    :samoyeds    => 2,
    :pomeranians => 3,
    :akitas      => 0,
    :vizslas     => 0,
    :goldfish    => 5,
    :trees       => 3,
    :cars        => 2,
    :perfumes    => 1,
  }.freeze

  WANTED_RELOP = {
    :cats        => :gt,
    :trees       => :gt,
    :pomeranians => :lt,
    :goldfish    => :lt,
  }.freeze

  def self.read_input
    File.read(File.expand_path("../input.txt", __FILE__))
  end

  def self.find_aunt(aunts, wanted, relop = {})
    wanted_aunts = aunts.select { |aunt| aunt.match?(wanted, relop) }
    raise "Failed to find aunt that matches criteria." if wanted_aunts.empty?
    raise "Failed to find uniquely matching aunt." if wanted_aunts.size != 1
    wanted_aunts.first
  end

  def self.main
    aunts = []

    lines = read_input.split("\n").reject(&:empty?)
    lines.each { |line| aunts << Aunt.from_line(line) }

    puts "Part One: #{find_aunt(aunts, WANTED).number}"
    puts "Part Two: #{find_aunt(aunts, WANTED, WANTED_RELOP).number}"
  end
end

Day16.main if "main" == to_s
