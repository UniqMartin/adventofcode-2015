# Advent of Code 2015 - Day 22

class Character
  attr_reader :hit_points

  def initialize(hit_points)
    @hit_points = hit_points
  end

  def to_s
    "#{self.class.name}: #{hit_points} HP"
  end
end

class Player < Character
  attr_reader :mana
  attr_reader :mode

  def self.default(opts = {})
    new(50, 500, opts.fetch(:mode, :easy))
  end

  def initialize(hit_points, mana, mode)
    super(hit_points)

    @mana = mana
    @mode = mode
  end

  def to_s
    "#{super}, #{mana} mana (#{mode} mode)"
  end
end

class Boss < Character
  attr_reader :damage

  def self.from_lines(lines)
    hit_points = nil
    damage = nil

    lines.map { |line| /^(.+): (\d+)$/.match(line)[1..2] }.each do |key, value|
      case key
      when "Hit Points" then hit_points = value.to_i
      when "Damage"     then damage = value.to_i
      else
        raise "Unrecognized boss stat '#{key}."
      end
    end

    new(hit_points, damage)
  end

  def initialize(hit_points, damage)
    super(hit_points)

    @damage = damage
  end

  def to_s
    "#{super}, #{damage} damage"
  end
end

module PlayerSpells
  SPELLS = {
    :magic_missile => {
      :costs => 53,
      :instant_damage => 4,
    },
    :drain => {
      :costs => 73,
      :instant_damage => 2,
      :instant_healing => 2,
    },
    :shield => {
      :costs => 113,
      :lasts => 6,
      :lasting_armor => 7,
    },
    :poison => {
      :costs => 173,
      :lasts => 6,
      :lasting_damage => 3,
    },
    :recharge => {
      :costs => 229,
      :lasts => 5,
      :lasting_mana => 101,
    },
  }.freeze
end

class GameStateUpdater
  include PlayerSpells

  attr_reader :base_state
  attr_reader :mana_spent
  attr_reader :spells

  def initialize(base_state)
    @base_state = base_state
    @mana_spent = base_state.mana_spent
    @spells = []

    @boss_hit_points = 0
    @player_hit_points = 0
    @player_mana = 0
  end

  def process_update(update)
    process_spells(update)
    process_boss(update)
    process_player(update)
    self
  end

  def next_state
    GameState.new(base_state.turn + 1, boss, player, spells, mana_spent)
  end

  private

  def apply_spells(update, active_spells)
    active_spells.each do |spell_id, _timer|
      SPELLS[spell_id].each do |property, value|
        case property
        when :lasting_armor
          # Is taken into account in `GameState#player_armor`.
        when :lasting_damage
          update[:boss] << [:hit_points, -value]
        when :lasting_mana
          update[:player] << [:mana, value]
        when :costs, :lasts
          # Ignore properties without lasting effect.
        else
          raise "Unrecognized lasting spell property '#{property}'."
        end
      end
    end
  end

  def boss
    old_boss = base_state.boss
    if @boss_hit_points != 0
      Boss.new(old_boss.hit_points + @boss_hit_points, old_boss.damage)
    else
      old_boss
    end
  end

  def player
    old_player = base_state.player
    if @player_hit_points != 0 || @player_mana != 0
      Player.new(old_player.hit_points + @player_hit_points,
                 old_player.mana + @player_mana,
                 old_player.mode)
    else
      old_player
    end
  end

  def process_boss(update)
    update[:boss].each do |property, delta|
      case property
      when :hit_points
        @boss_hit_points += delta
      end
    end
  end

  def process_player(update)
    update[:player].each do |property, delta|
      case property
      when :hit_points
        @player_hit_points += delta
      when :mana
        @player_mana += delta
        @mana_spent -= delta if delta < 0
      end
    end
  end

  def process_spells(update)
    apply_spells(update, base_state.spells)
    apply_spells(update, update[:spells])
    update_spells(update[:spells])
  end

  def update_spells(new_spells)
    base_state.spells.each do |spell_id, timer|
      next if timer <= 1
      spells << [spell_id, timer - 1]
    end

    new_spells.each do |spell_id, timer|
      spells << [spell_id, timer - 1]
    end
  end
end

class GameState
  include PlayerSpells

  attr_reader :turn
  attr_reader :boss
  attr_reader :player
  attr_reader :spells
  attr_reader :mana_spent

  def self.first(boss, player)
    new(1, boss, player, [], 0)
  end

  def initialize(turn, boss, player, spells, mana_spent)
    @turn = turn
    @boss = boss
    @player = player
    @spells = spells
    @mana_spent = mana_spent
  end

  def game_over?
    boss.hit_points <= 0 || player.hit_points <= 0
  end

  def next(option)
    update = Hash.new { |hash, key| hash[key] = [] }
    if turn.even?
      boss_update(update)
    else
      update[:player] << [:hit_points, -1] if player.mode == :hard
      player_update(update, option)
    end
    apply_update(update)
  end

  def options
    if game_over?
      []
    elsif turn.even?
      [:attack]
    else
      player_options
    end
  end

  def to_s
    winner_message = winner && " (#{winner} won)"

    "Turn #{turn} starts with#{winner_message}:\n" \
    "  #{player}\n" \
    "  #{boss}\n" \
    "  Active spells: #{spells.inspect}\n" \
    "  Options for #{who}: #{options.inspect}\n" \
    "  Total mana spent: #{mana_spent}"
  end

  def who
    turn.even? ? :boss : :player
  end

  def winner
    if player.hit_points <= 0
      :boss
    elsif boss.hit_points <= 0
      :player
    end
  end

  private

  def boss_update(update)
    player_damage = [1, boss.damage - player_armor].max
    update[:player] << [:hit_points, -player_damage]
  end

  def player_armor
    armor = 0
    spells.each do |spell_id, _timer|
      armor_bonus = SPELLS[spell_id][:lasting_armor]
      armor += armor_bonus if armor_bonus
    end
    armor
  end

  def player_options
    options = []
    SPELLS.each do |spell, info|
      next if info[:costs] > player.mana
      next if spells.map(&:first).include?(spell)
      options << spell
    end
    options
  end

  def player_update(update, spell)
    SPELLS[spell].each do |prop, value|
      case prop
      when :costs
        update[:player] << [:mana, -value]
      when :instant_damage
        update[:boss] << [:hit_points, -value]
      when :instant_healing
        update[:player] << [:hit_points, +value]
      when :lasts
        update[:spells] << [spell, value]
      when :lasting_armor, :lasting_damage, :lasting_mana
        # Ignore properties without immediate effect.
      else
        raise "Unrecognized instant spell property '#{prop}'."
      end
    end
  end

  def apply_update(update)
    GameStateUpdater.new(self).process_update(update).next_state
  end
end

class Game
  attr_reader :initial_state

  def initialize(boss, player, opts = {})
    @initial_state = GameState.first(boss, player)
    @debug = opts.fetch(:debug, false)
  end

  def win_with_minimal_mana
    @depth_limit = 10
    @mana_limit = nil

    # The idea is to successively raise the depth limit until we find a minimal
    # amount of mana that still allows us to win and also exhaust the entire
    # search space by making sure none of the branches of the game state tree is
    # truncated because it hits the depth limit. (Simultaneously minimizing the
    # mana limit helps to keep the search space small.)
    done = false
    until done
      reset_counters
      make_turn([], initial_state)
      print_statistics if @debug

      if @count_depth_limit == 0
        done = true
      else
        @depth_limit += @mana_limit ? 10 : 1
      end
    end

    raise "Failed to win minimal mana usage." if @mana_limit.nil?
    @mana_limit
  end

  private

  def make_turn(turns, state)
    if @mana_limit && state.mana_spent >= @mana_limit
      @count_mana_limit += 1
      return
    end

    if state.game_over?
      record_game_over(turns, state)
      return
    end

    if turns.size >= @depth_limit
      @count_depth_limit += 1
      return
    end

    state.options.each do |option|
      next_state = state.next(option)
      make_turn(turns + [option], next_state)
    end
  end

  def print_statistics
    totals = [
      ["player lost", @count_lost],
      ["player won", @count_won],
      ["depth limit", @count_depth_limit],
      ["mana limit", @count_mana_limit],
    ]
    totals << ["total", totals.map(&:last).reduce(0, :+)]
    digits = totals.last.last.to_s.length

    puts "[debug] Truncated search (with depth limit #{@depth_limit}) due to:"
    totals.each do |label, count|
      puts format("[debug]   %-11s ... %*d", label, digits, count)
    end
  end

  def record_game_over(turns, state)
    if state.winner == :boss
      @count_lost += 1
    else
      @count_won += 1
      @mana_limit = state.mana_spent
      if @debug
        puts "[debug] New mana limit: #{@mana_limit} (#{turns.size} turns)"
        puts state.to_s.split("\n").map { |l| "[debug]   #{l}" }
      end
    end
  end

  def reset_counters
    @count_lost = 0
    @count_won = 0
    @count_depth_limit = 0
    @count_mana_limit = 0
  end
end

module Day22
  def self.read_input
    File.read(File.expand_path("../input.txt", __FILE__))
  end

  def self.main
    boss = Boss.from_lines(read_input.split("\n").reject(&:empty?))

    easy_game = Game.new(boss, Player.default)
    hard_game = Game.new(boss, Player.default(:mode => :hard))

    puts "Part One: #{easy_game.win_with_minimal_mana}"
    puts "Part Two: #{hard_game.win_with_minimal_mana}"
  end
end

Day22.main if "main" == to_s
