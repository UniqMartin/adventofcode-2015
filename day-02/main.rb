# Advent of Code 2015 - Day 2

def read_input
  File.read(File.expand_path("../input.txt", __FILE__))
end

def one_paper(l, w, h)
  area = 2 * (l * w + l * h + w * h)
  slack = l * w # relies on [l, w, h] being sorted
  area + slack
end

def one_ribbon(l, w, h)
  2 * (l + w) + l * w * h # relies on [l, w, h] being sorted
end

def main
  input = read_input.split("\n").reject(&:empty?)

  paper = 0
  ribbon = 0

  input.each do |line|
    dims = line.split("x").map(&:to_i).sort
    paper += one_paper(*dims)
    ribbon += one_ribbon(*dims)
  end

  puts "Part One: #{paper}" # square feet of wrapping paper
  puts "Part Two: #{ribbon}" # feet of ribbon
end

main if "main" == to_s
