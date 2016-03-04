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

  def dump_graph
    node_index = 0
    node_id = Hash.new { |h, k| h[k] = format("N_%04d", node_index += 1) }

    puts "digraph G {"
    gates.each do |gate_output, gate|
      dump_graph_gate(node_id, gate_output, gate)
    end
    puts "}"
    exit 0
  end

  def eval(name)
    gates[name].eval(self)
  end

  def flush
    gates.each_value(&:flush)
    self
  end

  private

  def dump_graph_gate(node_id, gate_output, gate)
    ovar_node = node_id["var:#{gate_output}"]
    gate_node = node_id["gate:#{gate_output}"]
    gate_label = gate.op.to_s.sub(/^eval_/, "").upcase

    puts "  #{ovar_node} [share=circle,label=\"#{gate_output}\"];"
    puts "  #{gate_node} [shape=box,label=\"#{gate_label}\"];"
    puts "  #{gate_node} -> #{ovar_node};"

    dump_graph_gate_inputs(node_id, gate_output, gate.input, gate_node)
  end

  def dump_graph_gate_inputs(node_id, gate_output, gate_inputs, gate_node)
    is_unary = (gate_inputs.size == 1)

    gate_inputs.each_with_index do |input, index|
      edge_extra = is_unary ? "" : " [label=\"##{index + 1}\"]"
      case input
      when Constant
        const_node = node_id["const:#{gate_output}/#{index}"]
        puts "  #{const_node} [shape=octagon,label=\"= #{input.value}\"];"
        puts "  #{const_node} -> #{gate_node}#{edge_extra};"
      when Variable
        ivar_node = node_id["var:#{input.name}"]
        puts "  #{ivar_node} -> #{gate_node}#{edge_extra};"
      end
    end
  end
end

def read_circuit
  circuit = Circuit.new

  gates = read_input.split("\n").reject(&:empty?)
  gates.each { |line| circuit.add_gate(line) }

  circuit
end

def dump_graph_and_exit(circuit)
  circuit.dump_graph
  exit 0
end

def main
  circuit = read_circuit
  dump_graph_and_exit(circuit) if ARGV == %w[--graph]

  a_one = circuit.eval("a")
  a_two = circuit.flush.add_gate("#{a_one} -> b").eval("a")

  puts "Part One: #{a_one}"
  puts "Part Two: #{a_two}"
end

main if "main" == to_s
