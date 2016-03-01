# Advent of Code 2015 - Day 18

require "matrix"

class LightArray
  attr_reader :cols
  attr_reader :rows
  attr_reader :matrix

  def self.from_lines(lines, opts = {})
    matrix = lines.map do |line|
      line.chars.map { |char| char == "#" ? 1 : 0 }
    end
    new(Matrix[*matrix], opts)
  end

  def initialize(matrix, opts = {})
    @stuck_corners = opts.fetch(:stuck_corners, false)
    @cols = matrix.column_size
    @rows = matrix.row_size
    @matrix = add_border(matrix)
    @ncount = nil
  end

  def count_on
    count = 0
    matrix.each { |el| count += el }
    count
  end

  def step(steps = 1)
    steps.times do
      @ncount = build_ncount
      @matrix = matrix + build_update
    end
    self
  end

  def to_s
    s = ""
    rows.times do |row|
      row_array = matrix.row(row + 1).to_a[1..-2]
      s << row_array.map { |v| v == 1 ? "#" : "." }.join
      s << "\n"
    end
    s
  end

  private

  def add_border(matrix)
    Matrix.build(rows + 2, cols + 2) do |row, col|
      if corner?(row, col)
        1
      elsif update?(row, col)
        matrix[row - 1, col - 1]
      else
        0
      end
    end
  end

  # Build matrix with counts of switched-on neighbors.
  def build_ncount
    Matrix.build(rows, cols) do |row, col|
      count = 0
      3.times do |row_off|
        3.times do |col_off|
          count += matrix[row + row_off, col + col_off]
        end
      end
      count - matrix[row + 1, col + 1]
    end
  end

  # Build matrix with cell updates (-1 = switch off, +1 = switch on, 0 = keep).
  def build_update
    Matrix.build(rows + 2, cols + 2) do |row, col|
      if corner?(row, col)
        0
      elsif update?(row, col)
        update_for_cell(row, col)
      else
        0
      end
    end
  end

  def corner?(row, col)
    return false unless @stuck_corners
    (row == 1 || row == rows) && (col == 1 || col == cols)
  end

  def update?(row, col)
    row > 0 && row <= rows && col > 0 && col <= cols
  end

  def update_for_cell(row, col)
    ncount = @ncount[row - 1, col - 1]
    if matrix[row, col] == 1
      (ncount == 2 || ncount == 3) ? 0 : -1
    else
      ncount != 3 ? 0 : +1
    end
  end
end

module Day18
  NUM_STEPS = 100

  def self.read_input
    File.read(File.expand_path("../input.txt", __FILE__))
  end

  def self.main
    lines = read_input.split("\n").reject(&:empty?)

    part_one = LightArray.from_lines(lines)
    part_two = LightArray.from_lines(lines, :stuck_corners => true)

    puts "Part One: #{part_one.step(NUM_STEPS).count_on}"
    puts "Part Two: #{part_two.step(NUM_STEPS).count_on}"
  end
end

Day18.main if "main" == to_s
