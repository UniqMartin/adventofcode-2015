# Advent of Code 2015 - Day 6

def read_input
  File.read(File.expand_path("../input.txt", __FILE__))
end

class Range
  def empty?
    size == 0
  end

  def intersect(other)
    overlap = [min, other.min].max..[max, other.max].min
    parts = overlap.empty? ? [self] : parts_from_overlap(overlap)
    [!overlap.empty?, parts]
  end

  private

  def parts_from_overlap(overlap)
    parts = [overlap]
    parts << (min..overlap.min - 1) if min < overlap.min
    parts << (overlap.max + 1..max) if overlap.max < max
    parts
  end
end

class Rect
  attr_reader :x_lim
  attr_reader :y_lim

  def initialize(x_lim, y_lim)
    @x_lim = x_lim
    @y_lim = y_lim
  end

  def width
    x_lim.size
  end

  def height
    y_lim.size
  end

  def area
    width * height
  end

  def intersect(other)
    x_hit, x_parts = x_lim.intersect(other.x_lim)
    y_hit, y_parts = y_lim.intersect(other.y_lim)
    return [yield(false, x_lim, y_lim)] unless x_hit && y_hit

    hit = [true]
    x_parts.flat_map do |x|
      y_parts.map do |y|
        yield(hit.pop || false, x, y)
      end
    end
  end
end

class LightRect < Rect
  attr_reader :brightness

  def initialize(x_lim, y_lim, brightness = 0)
    super(x_lim, y_lim)
    @brightness = brightness
  end

  def intersect(other, brightness_hit)
    brightness_old = brightness
    super(other) do |hit, x, y|
      LightRect.new(x, y, hit ? brightness_hit : brightness_old)
    end
  end

  def area_brightness
    area * brightness
  end
end

class LightArray
  attr_reader :rects

  def initialize
    @rects = [LightRect.new(0..999, 0..999)]
  end

  def brightness
    rects.map(&:area_brightness).reduce(0, :+)
  end

  def update(op, other_rect)
    @rects = rects.flat_map do |rect|
      rect.intersect(other_rect, map_brightness(op, rect.brightness))
    end
  end
end

class BinaryLightArray < LightArray
  def map_brightness(op, brightness)
    case op
    when :toggle   then 1 - brightness
    when :turn_off then 0
    when :turn_on  then 1
    end
  end
end

class SteppedLightArray < LightArray
  def map_brightness(op, brightness)
    case op
    when :toggle   then brightness + 2
    when :turn_off then [brightness - 1, 0].max
    when :turn_on  then brightness + 1
    end
  end
end

class Command
  COMMAND_REGEXP = /^(toggle|turn (?:off|on)) (\d+),(\d+) through (\d+),(\d+)$/

  attr_reader :action
  attr_reader :rect

  def self.parse(line)
    action, *rect = line.match(COMMAND_REGEXP)[1..5]
    x_min, y_min, x_max, y_max = rect.map(&:to_i)

    new(action.tr(" ", "_").to_sym, Rect.new(x_min..x_max, y_min..y_max))
  end

  def initialize(action, rect)
    @action = action
    @rect = rect
  end

  def apply(array)
    array.update(action, rect)
  end
end

def apply_commands(array, commands)
  commands.each { |command| command.apply(array) }
  array
end

def main
  commands = read_input.split("\n").reject(&:empty?)
  commands = commands.map { |line| Command.parse(line) }

  binary_array = apply_commands(BinaryLightArray.new, commands)
  stepped_array = apply_commands(SteppedLightArray.new, commands)

  puts "Part One: #{binary_array.brightness}"
  puts "Part Two: #{stepped_array.brightness}"
end

main if "main" == to_s
