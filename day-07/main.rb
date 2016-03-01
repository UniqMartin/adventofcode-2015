# Advent of Code 2015 - Day 7

def read_input
  File.read(File.expand_path("../input.txt", __FILE__))
end

class Constant
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def fetch(_circuit)
    value
  end
end

class Variable
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def fetch(circuit)
    circuit.eval(name)
  end
end

module GateEvaluators
  private

  def eval_and(left, right)
    left & right
  end

  def eval_lshift(value, shift)
    value << shift
  end

  def eval_not(value)
    ~value
  end

  def eval_or(left, right)
    left | right
  end

  def eval_rshift(value, shift)
    value >> shift
  end

  def eval_value(value)
    value
  end
end

class Gate
  include GateEvaluators

  attr_reader :input
  attr_reader :op

  def initialize(op, input)
    @op = "eval_#{op.downcase}".to_sym
    @input = input
  end

  def eval(circuit)
    @value ||= uncached_eval(circuit)
  end

  def flush
    @value = nil
  end

  private

  def uncached_eval(circuit)
    args = input.map { |value| value.fetch(circuit) }
    send(op, *args)
  end
end

class GateBuilder
  GATE_REGEXP = /^(.+) -> ([a-z]+)$/
  BINARY_REGEXP = /^([a-z]+|\d+) ([A-Z]+) ([a-z]+|\d+)$/
  UNARY_REGEXP = /^([A-Z]+) ([a-z]+|\d+)$/
  VALUE_REGEXP = /^([a-z]+|\d+)$/
  CONSTANT_REGEXP = /^\d+$/

  def self.split_line(line)
    input_expr, output = line.match(GATE_REGEXP)[1..2]
    case input_expr
    when BINARY_REGEXP then [output] + Regexp.last_match.values_at(2, 1, 3)
    when UNARY_REGEXP  then [output] + Regexp.last_match.values_at(1, 2)
    when VALUE_REGEXP  then [output, "VALUE"] + Regexp.last_match.values_at(1)
    else
      raise "Not recognized: #{line}"
    end
  end

  def self.constant?(str)
    str[CONSTANT_REGEXP]
  end
end

class Circuit
  attr_reader :gates

  def initialize
    @gates = {}
  end

  def add_gate(line)
    output, op, *input = GateBuilder.split_line(line)
    input = input.map do |value|
      if GateBuilder.constant?(value)
        Constant.new(value.to_i)
      else
        Variable.new(value)
      end
    end
    gates[output] = Gate.new(op, input)
    self
  end

  def eval(name)
    gates[name].eval(self)
  end

  def flush
    gates.each_value(&:flush)
    self
  end
end

def main
  circuit = Circuit.new

  gates = read_input.split("\n").reject(&:empty?)
  gates.each { |line| circuit.add_gate(line) }

  a_one = circuit.eval("a")
  a_two = circuit.flush.add_gate("#{a_one} -> b").eval("a")

  puts "Part One: #{a_one}"
  puts "Part Two: #{a_two}"
end

main if "main" == to_s
