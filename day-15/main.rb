# Advent of Code 2015 - Day 15

require "matrix"

class Ingredient
  attr_reader :name
  attr_reader :properties
  attr_reader :limit

  def initialize(name, properties)
    @name = name
    @properties = properties
    @limit = nil
  end

  def update_limit(num_total, others)
    limits = properties.select { |_, num| num < 0 }.map do |property, value|
      limit_for_property(num_total, others, property, value)
    end
    @limit = limits.min || num_total
  end

  private

  # Maximum teaspoons of self that can still be balanced by any of the other
  # ingredients (i.e. have a positive value value for the same property).
  def limit_for_property(num_total, others, property, value)
    positive_others = others.select { |other| other.properties[property] > 0 }
    limits = positive_others.map do |other|
      balance_property(num_total, value, other.properties[property])
    end
    limits.max || num_total
  end

  # Maximum teaspoons of self (with a negative property value) that can still be
  # balanced by the given ingredient (has positive value for the same property).
  def balance_property(num_total, value, other_value)
    ((-other_value.to_f * num_total) / (value - other_value)).floor
  end
end

class Recipe
  INGREDIENT_REGEXP = /^(\w+): (.*)$/
  PROPERTY_REGEXP = /(\w+) ([+-]?\d+)/

  attr_reader :debug
  attr_reader :ingredients
  attr_reader :num_total

  def initialize(num_total, debug = false)
    @debug = debug
    @ingredients = []
    @num_total = num_total
  end

  def add_ingredient(line)
    name, properties = line.match(INGREDIENT_REGEXP)[1..2]
    properties = Hash[
      properties.scan(PROPERTY_REGEXP).map { |k, v| [k.to_sym, v.to_i] }
    ]
    ingredients << Ingredient.new(name, properties)
  end

  def best_score(opts = {}) # rubocop:disable Metrics/AbcSize
    calory_target = opts[:calory_target]
    weights, calory_weights = setup_weights
    scores = []

    try_ingredients do |parts|
      parts_vec = Vector[*parts]
      property_scores = weights * parts_vec
      next if property_scores.any? { |e| e <= 0 }
      next if calory_target && (calory_weights * parts_vec)[0] != calory_target
      scores << [property_scores.reduce(1, :*), parts]
    end

    raise "Failed to find valid ingredient combinations." if scores.empty?
    debug_best_score(scores) if debug
    scores.max_by(&:first).first
  end

  private

  def debug_best_score(scores)
    number = 10
    top_10 = scores.sort_by(&:first).reverse.first(number)
    digits = top_10.first.first.to_s.length
    puts "[debug] Top #{number} results (of #{scores.size} valid):"
    top_10.each do |score, parts|
      puts format("[debug]   %*d for %s", digits, score, parts.inspect)
    end
  end

  def setup_weights
    weights = ingredients.map(&:properties).map(&:values).transpose

    calory_index = ingredients.first.properties.keys.index(:calories)
    calory_weights = weights.delete_at(calory_index)

    [Matrix[*weights], Matrix[calory_weights]]
  end

  def try_ingredients(&block)
    update_ingredient_limits
    limits = ingredients.map(&:limit)
    parts = [0] * limits.size
    try_ingredient(0, 0, parts, limits, &block)
  end

  def try_ingredient(index, sub_total, parts, limits, &block)
    remaining = num_total - sub_total
    next_index = index + 1
    if next_index == limits.size
      parts[index] = remaining
      yield parts.dup
    else
      limit = [remaining, limits[index]].min
      (0..limit).each do |num|
        parts[index] = num
        try_ingredient(next_index, sub_total + num, parts, limits, &block)
      end
    end
  end

  def update_ingredient_limits
    ingredients.each_with_index do |ingredient, index|
      others = ingredients.dup
      others.delete_at(index)
      ingredient.update_limit(num_total, others)
    end
  end
end

module Day15
  NUM_CALORIES = 500
  NUM_TEASPOONS = 100

  def self.read_input
    File.read(File.expand_path("../input.txt", __FILE__))
  end

  def self.main
    recipe = Recipe.new(NUM_TEASPOONS)

    lines = read_input.split("\n").reject(&:empty?)
    lines.each { |line| recipe.add_ingredient(line) }

    puts "Part One: #{recipe.best_score}"
    puts "Part Two: #{recipe.best_score(:calory_target => NUM_CALORIES)}"
  end
end

Day15.main if "main" == to_s
