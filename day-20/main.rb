# Advent of Code 2015 - Day 20

require "prime"

module Day20
  INPUT_PRESENTS = 34_000_000

  def self.factors_of(number)
    factors = [1]

    primes = Prime.prime_division(number)
    primes.each do |prime, max_power|
      count = factors.size
      1.upto(max_power) do |power|
        factor = prime**power
        count.times do |index|
          factors << factor * factors[index]
        end
      end
    end

    factors
  end

  def self.sum_of_factors(number)
    # Slightly faster version of `factors_of(number).reduce(0, :+)`.
    total = 1
    primes = Prime.prime_division(number)
    primes.each do |prime, max_power|
      total *= (prime**(max_power + 1) - 1) / (prime - 1)
    end
    total
  end

  def self.sum_of_factors_with_limit(number, limit)
    total = number
    2.upto(limit) { |x| total += number / x if number % x == 0 }
    total
  end

  def self.find_first_house(per_elf, min_presents)
    2.upto(min_presents / per_elf + 1) do |house|
      presents = per_elf * sum_of_factors(house)

      return house if presents >= min_presents
    end

    raise "Exhausted search space without finding the house (bug?)."
  end

  def self.find_first_house_with_limit(per_elf, min_presents, limit)
    2.upto(min_presents / per_elf + 1) do |house|
      presents = per_elf * sum_of_factors_with_limit(house, limit)

      return house if presents >= min_presents
    end

    raise "Exhausted search space without finding the house (bug?)."
  end

  def self.main
    part_one = find_first_house(10, INPUT_PRESENTS)
    part_two = find_first_house_with_limit(11, INPUT_PRESENTS, 50)

    puts "Part One: #{part_one}"
    puts "Part Two: #{part_two}"
  end
end

Day20.main if to_s == "main"
