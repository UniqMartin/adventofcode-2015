"""Advent of Code 2015 - Day 7."""

import os
import re


def read_input():
    """Read input file and split into individual lines returned as a list."""
    base = os.path.abspath(os.path.dirname(__file__))
    file = os.path.join(base, 'input.txt')
    return open(file).read().splitlines()


class Literal(object):
    """Literal with an integer value."""

    def __init__(self, value):
        """Initialize a literal with its value."""
        self.value = value


class Variable(object):
    """Variable with a name."""

    def __init__(self, name):
        """Initialize a variable with its name."""
        self.name = name


class Gate(object):
    """Gate representing a constant, variable, or bit-wise operation."""

    # Regular expression for parsing gate expressions.
    EXPR_REGEXP = re.compile(r'^(?:(?:([a-z]+|\d+) )?([A-Z]+) )?([a-z]+|\d+)$')

    @classmethod
    def from_expr(cls, expr):
        """Initialize a gate by parsing an expression."""
        lhs, operator, rhs = cls.EXPR_REGEXP.search(expr).groups()

        return cls(cls._parse_operand(lhs), operator, cls._parse_operand(rhs))

    @staticmethod
    def _parse_operand(operand):
        """Parse operand and return a literal, a variable, or nothing."""
        if operand is None:
            return None
        elif re.search(r'^\d+$', operand):
            return Literal(int(operand))
        else:
            return Variable(operand)

    def __init__(self, lhs, operator, rhs):
        """Initialize a gate from LHS, operator, and RHS."""
        self._value = None
        self.lhs = lhs
        self.operator = operator
        self.rhs = rhs

    def eval(self, circuit):
        """Evaluate the value of the gate and cache it for later retrieval."""
        if self._value is None:
            self._value = self._eval(circuit)

        return self._value

    def flush(self):
        """Flush cache with previously computed gate value."""
        self._value = None

    def _eval(self, circuit):
        """Prepare operands and perform actual evaluation of the gate."""
        lhs = self._fetch(circuit, self.lhs)
        rhs = self._fetch(circuit, self.rhs)
        if self.operator is None:
            return rhs
        elif self.operator == 'AND':
            return lhs & rhs
        elif self.operator == 'LSHIFT':
            return lhs << rhs
        elif self.operator == 'NOT':
            return ~rhs
        elif self.operator == 'OR':
            return lhs | rhs
        elif self.operator == 'RSHIFT':
            return lhs >> rhs

    def _fetch(self, circuit, operand):
        """Fetch operand, possibly delegating to circuit for wire reference."""
        if operand is None:
            return None
        elif isinstance(operand, Literal):
            return operand.value
        elif isinstance(operand, Variable):
            return circuit.eval(operand.name)


class Circuit(object):
    """Logic circuit represented by a bunch of named gates."""

    # Regular expression for parsing gates from the input file.
    GATE_REGEXP = re.compile(r'^(.+) -> ([a-z]+)$')

    @classmethod
    def from_lines(cls, lines):
        """Initialize a logic circuit from lines from the input file."""
        circuit = cls()
        for line in lines:
            expr, wire = cls.GATE_REGEXP.search(line).groups()
            circuit.wire_gate(wire, expr)

        return circuit

    def __init__(self):
        """Initialize an empty logic circuit."""
        self.gates = {}

    def eval(self, wire):
        """Evaluate a wire by asking the associated gate for its value."""
        return self.gates[wire].eval(self)

    def flush(self):
        """Flush caches of all gates in the circuit."""
        for gate in self.gates.values():
            gate.flush()

        # Simplify chaining method calls.
        return self

    def wire_gate(self, wire, expr):
        """Parse a gate expression and assign it to a wire."""
        self.gates[wire] = Gate.from_expr(expr)

        # Simplify chaining method calls.
        return self


def main():
    """Main entry point of puzzle solution."""
    circuit = Circuit.from_lines(read_input())

    part_one = circuit.eval('a')
    part_two = circuit.flush().wire_gate('b', str(part_one)).eval('a')

    print('Part One: {}'.format(part_one))
    print('Part Two: {}'.format(part_two))


if __name__ == '__main__':
    main()
