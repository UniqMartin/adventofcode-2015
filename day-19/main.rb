# Advent of Code 2015 - Day 19

module Day19
  TEST_LINES = [
    "e => H",
    "e => O",
    "H => HO",
    "H => OH",
    "O => HH",
    "HOHOHO", # HOH, HOHOHO, H2O
  ].freeze
  MAX_CONTRACTIONS = 5000

  def self.read_input
    File.read(File.expand_path("../input.txt", __FILE__))
  end

  def self.parse_lines(lines)
    replacements = parse_replacements(lines[0..-2])
    molecule = parse_molecule(lines.last)

    [molecule, replacements]
  end

  def self.parse_replacements(lines)
    replacements = Hash.new { |hash, atom| hash[atom] = [] }

    lines.each do |line|
      atom, combo = line.match(/^(\w+) => (\w+)$/)[1..2]
      replacements[atom] << combo
    end

    replacements
  end

  def self.parse_molecule(line)
    line.scan(/[A-Z][a-z]*/)
  end

  def self.collect_variants(replacements, molecule)
    variants = []

    molecule.each_with_index do |part, index|
      next unless replacements.key?(part)

      prefix = molecule[0...index]
      suffix = molecule[(index + 1)..-1]
      replacements[part].each do |subs|
        variants << (prefix + [subs] + suffix).join
      end
    end

    variants
  end

  def self.invert_replacements(replacements)
    inverse = {}

    replacements.each do |atom, combo_list|
      combo_list.each do |combo|
        raise "Expected replacements to be unique." if inverse.key?(combo)
        inverse[combo] = [atom, parse_molecule(combo).size]
      end
    end

    inverse
  end

  def self.find_contraction(replacements, molecule)
    contractions = []

    replacements.each do |combo, (atom, pieces)|
      contractions << [pieces, combo, atom] if molecule.include?(combo)
    end
    raise "Failed to find a valid contraction." if contractions.empty?

    # Select contraction that maximally reduces the number of atoms.
    contractions.max_by(&:first)[1..2]
  end

  def self.contract_molecule(replacements, molecule)
    replacements = invert_replacements(replacements)
    molecule = molecule.join("")

    molecule_history = []
    MAX_CONTRACTIONS.times do
      combo, atom = find_contraction(replacements, molecule)
      molecule.sub!(combo, atom)
      molecule_history << molecule.dup

      return molecule_history if molecule == "e"
    end

    raise "Failed to contract molecule after #{MAX_CONTRACTIONS} iterations."
  end

  def self.debug_parse_lines(replacements, molecule)
    puts "[debug] Replacements:"
    replacements.each do |key, rep|
      puts "[debug]   #{key} => #{rep.inspect}"
    end
    print "[debug] Molecule: "
    puts molecule.map { |el| replacements.key?(el) ? el : "*#{el}" }.join(" ")
  end

  def self.debug_contraction_molecule_history(history)
    history.each_with_index do |molecule, index|
      puts format("[debug] Step %4d: %4d atoms",
                  index + 1,
                  parse_molecule(molecule).size)
    end
  end

  def self.main
    lines = read_input.split("\n").reject(&:empty?)
    molecule, replacements = parse_lines(lines)

    part_one = collect_variants(replacements, molecule).uniq
    part_two = contract_molecule(replacements, molecule)

    puts "Part One: #{part_one.size}"
    puts "Part Two: #{part_two.size}"
  end
end

Day19.main if "main" == to_s
