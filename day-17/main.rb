# Advent of Code 2015 - Day 17

module Day17
  EGGNOG_VOLUME = 150

  def self.read_input
    File.read(File.expand_path("../input.txt", __FILE__))
  end

  # Infer list of set bits in value from its base-2 string representation.
  def self.bits_in_value(value, bits)
    bytes = value.to_s(2).rjust(bits, "0").bytes # "1" is odd
    index = []
    bytes.each_with_index.select { |v, i| index << i if v.odd? }
    index
  end

  def self.precompute_half(items)
    sums = Hash.new { |hash, key| hash[key] = [] }
    bits = items.size
    (2**bits).times do |value|
      index = bits_in_value(value, bits)
      sizes = items.values_at(*index)
      sums[sizes.reduce(0, :+)] << sizes
    end
    sums
  end

  def self.precompute_sums(items)
    raise "Item list too short." if items.size < 2

    middle = items.size / 2
    l_half = precompute_half(items[0...middle])
    r_half = precompute_half(items[middle..-1])
    [l_half, r_half]
  end

  # Use a divide-and-conquer approach by computing the volumes of all possible
  # container combinations for the left and right side of the container list.
  # Then use that to find pairs whose summed volume matches the target volume.
  def self.enum_variants(items, target_volume)
    l_half, r_half = precompute_sums(items)

    variants = []
    l_half.each do |l_vol, l_sizes|
      r_vol = target_volume - l_vol
      next unless r_vol >= 0 && r_half.key?(r_vol)
      r_sizes = r_half[target_volume - l_vol]
      variants += enum_pair(l_sizes, r_sizes)
    end

    variants
  end

  def self.enum_pair(l_sizes, r_sizes)
    l_sizes.flat_map do |l_size|
      r_sizes.map { |r_size| l_size + r_size }
    end
  end

  def self.enum_shortest(variants)
    optimal_length = variants.map(&:length).min
    variants.select { |variant| variant.length == optimal_length }
  end

  def self.main
    containers = read_input.split("\n").reject(&:empty?).map(&:to_i)

    part_one = enum_variants(containers, EGGNOG_VOLUME)
    part_two = enum_shortest(part_one)

    puts "Part One: #{part_one.size}"
    puts "Part Two: #{part_two.size}"
  end
end

Day17.main if "main" == to_s
