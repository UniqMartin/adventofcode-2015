# Advent of Code 2015 - Day 21

class Character
  attr_reader :hit_points
  attr_reader :damage
  attr_reader :armor

  def initialize(hit_points, damage, armor)
    @hit_points = hit_points
    @damage = damage
    @armor = armor
  end

  def to_s
    "#{self.class.name}: #{hit_points} HP, #{damage} damage, #{armor} armor"
  end
end

class Player < Character
  def self.default
    new(100, 0, 0)
  end
end

class Boss < Character
  def self.from_lines(lines)
    hit_points = nil
    damage = nil
    armor = nil

    lines.map { |line| /^(.+): (\d+)$/.match(line)[1..2] }.each do |key, value|
      case key
      when "Hit Points" then hit_points = value.to_i
      when "Damage"     then damage = value.to_i
      when "Armor"      then armor = value.to_i
      else
        raise "Unrecognized boss stat '#{key}."
      end
    end

    new(hit_points, damage, armor)
  end
end

module PlayerItems
  # Entries: [Name, Cost, Damage, Armor]
  ITEMS = {
    :weapons => {
      :items => [
        ["Dagger", 8, 4, 0],
        ["Shortsword", 10, 5, 0],
        ["Warhammer", 25, 6, 0],
        ["Longsword", 40, 7, 0],
        ["Greataxe", 74, 8, 0],
      ],
      :use => 1..1, # 5 combinations
    },
    :armor => {
      :items => [
        ["Leather", 13, 0, 1],
        ["Chainmail", 31, 0, 2],
        ["Splintmail", 53, 0, 3],
        ["Bandedmail", 75, 0, 4],
        ["Platemail", 102, 0, 5],
      ],
      :use => 0..1, # 6 combinations
    },
    :rings => {
      :items => [
        ["Damage +1", 25, 1, 0],
        ["Damage +2", 50, 2, 0],
        ["Damage +3", 100, 3, 0],
        ["Defense +1", 20, 0, 1],
        ["Defense +2", 40, 0, 2],
        ["Defense +3", 80, 0, 3],
      ],
      :use => 0..2, # 22 combinations
    },
  }.freeze
end

module Day21
  def self.read_input
    File.read(File.expand_path("../input.txt", __FILE__))
  end

  def self.sum_item_stats(item_list)
    item_list.reduce([0, 0, 0]) do |memo, (cost, damage, armor)|
      [memo[0] + cost, memo[1] + damage, memo[2] + armor]
    end
  end

  def self.prepare_items_in_category(items, use_range)
    # Strip unused name from item list.
    items = items.map { |item| item[1..3] }

    # Compute [cost, damage, armor] for all valid combinations of items.
    use_range.to_a.flat_map do |use|
      items.size.times.to_a.combination(use).map do |item_indices|
        sum_item_stats(items.values_at(*item_indices))
      end
    end
  end

  def self.prepare_items
    per_category = PlayerItems::ITEMS.map do |_kind, info|
      prepare_items_in_category(info[:items], info[:use])
    end

    # Compute [cost, damage, armor] for all combinations across categories.
    items = []
    per_category[0].product(*per_category[1..-1]) do |item_list|
      items << sum_item_stats(item_list)
    end

    # Sort by cost, so cheapest combination of items is checked first.
    items.sort_by(&:first)
  end

  def self.boss_damage(boss, player, armor_bonus)
    [1, boss.damage - (player.armor + armor_bonus)].max
  end

  def self.player_damage(boss, player, damage_bonus)
    [1, (player.damage + damage_bonus) - boss.armor].max
  end

  def self.player_wins?(boss, player, damage_bonus, armor_bonus)
    b_rounds = (boss.hit_points - 1) / player_damage(boss, player, damage_bonus)
    p_rounds = (player.hit_points - 1) / boss_damage(boss, player, armor_bonus)

    p_rounds >= b_rounds
  end

  def self.cost_of_survival(boss, player, player_items)
    player_items.each do |cost, damage_bonus, armor_bonus|
      return cost if player_wins?(boss, player, damage_bonus, armor_bonus)
    end

    raise "Failed to find gear where player would win."
  end

  def self.price_of_death(boss, player, player_items)
    player_items.reverse_each do |cost, damage_bonus, armor_bonus|
      return cost unless player_wins?(boss, player, damage_bonus, armor_bonus)
    end

    raise "Failed to find gear where player would lose."
  end

  def self.main
    boss = Boss.from_lines(read_input.split("\n").reject(&:empty?))
    player = Player.default
    player_items = prepare_items

    puts "Part One: #{cost_of_survival(boss, player, player_items)}"
    puts "Part Two: #{price_of_death(boss, player, player_items)}"
  end
end

Day21.main if "main" == to_s
