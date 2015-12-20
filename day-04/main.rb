# Advent of Code 2015 - Day 4

INPUT_KEY = "ckczppom".freeze

require "digest"

def md5_with_prefix(input, prefix, number = 0)
  md5 = Digest::MD5.new

  loop do
    return number if md5.hexdigest("#{input}#{number}").start_with?(prefix)
    number += 1
  end
end

def main
  magic_one = md5_with_prefix(INPUT_KEY, "0" * 5)
  magic_two = md5_with_prefix(INPUT_KEY, "0" * 6, magic_one)

  puts "Part One: #{magic_one}" # magic number for MD5 with 5 leading zeros
  puts "Part Two: #{magic_two}" # ... and with 6 leading zeros
end

main if to_s == "main"
