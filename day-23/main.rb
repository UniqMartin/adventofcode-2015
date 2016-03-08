# Advent of Code 2015 - Day 23

class MachineState
  attr_accessor :ip

  def initialize(initial = {})
    @registers = { :a => 0, :b => 0 }.merge(initial)
    @ip = 0
  end

  def [](register)
    @registers[register]
  end

  def []=(register, value)
    @registers[register] = value
  end

  def step(offset = 1)
    @ip += offset
  end
end

class Instruction
  attr_reader :code
  attr_reader :register
  attr_reader :offset

  def initialize(code, register, offset)
    @code = code
    @register = register
    @offset = offset
  end

  def eval(state)
    send("eval_#{code}", state)
  end

  private

  def eval_hlf(state)
    state[register] /= 2
    state.step
  end

  def eval_tpl(state)
    state[register] *= 3
    state.step
  end

  def eval_inc(state)
    state[register] += 1
    state.step
  end

  def eval_jmp(state)
    state.step(offset)
  end

  def eval_jie(state)
    state.step(state[register].even? ? offset : 1)
  end

  def eval_jio(state)
    state.step(state[register] == 1 ? offset : 1)
  end
end

class Program
  ARITHMETIC_REGEXP = /^(hlf|tpl|inc) ([ab])$/
  JUMP_REGEXP = /^(jmp) ([+-]\d+)$/
  CONDITIONAL_JUMP_REGEXP = /^(jie|jio) ([ab]), ([+-]\d+)$/

  attr_reader :instructions

  def initialize
    @instructions = []
  end

  def add_line(line)
    args = case line
           when ARITHMETIC_REGEXP
             match_fetch(Regexp.last_match, 1, 2, nil)
           when JUMP_REGEXP
             match_fetch(Regexp.last_match, 1, nil, 2)
           when CONDITIONAL_JUMP_REGEXP
             match_fetch(Regexp.last_match, 1, 2, 3)
           else
             raise "Failed to parse line '#{line}'."
           end
    add_instruction(*args)
  end

  def run(initial = {})
    state = MachineState.new(initial)
    while state.ip >= 0 && state.ip < instructions.size
      instructions[state.ip].eval(state)
    end
    state
  end

  private

  def add_instruction(ins, reg, off)
    reg &&= reg.to_sym
    off &&= off.to_i
    instructions << Instruction.new(ins.to_sym, reg, off)
  end

  def match_fetch(match, *indices)
    indices.map { |index| index ? match[index] : nil }
  end
end

module Day23
  def self.read_input
    File.read(File.expand_path("../input.txt", __FILE__))
  end

  def self.main
    program = Program.new

    lines = read_input.split("\n").reject(&:empty?)
    lines.each { |line| program.add_line(line) }

    puts "Part One: #{program.run[:b]}"
    puts "Part Two: #{program.run(:a => 1)[:b]}"
  end
end

Day23.main if "main" == to_s
