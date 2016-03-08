# Advent of Code 2015 - Day 25

module Day25
  INPUT_START = 20_151_125
  INPUT_MUL = 252_533
  INPUT_MOD = 33_554_393

  def self.read_input
    File.read(File.expand_path("../input.txt", __FILE__))
  end

  def self.parse_input(input)
    result = {}
    input.scan(/(column|row) (\d+)/).each do |key, value|
      result[key.to_sym] = value.to_i
    end
    result
  end

  def self.subs_to_index(subs)
    diagonal = subs[:row] + subs[:column] - 1
    diagonal * (diagonal - 1) / 2 + subs[:column]
  end

  def self.index_to_code(index)
    code = INPUT_START
    (index - 1).times do
      code = (code * INPUT_MUL) % INPUT_MOD
    end
    code
  end

  def self.main
    index = subs_to_index(parse_input(read_input))

    puts "Part One: #{index_to_code(index)}"
    puts "Part Two: N/A"
  end
end

Day25.main if "main" == to_s
