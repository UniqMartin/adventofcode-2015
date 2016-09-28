"""Advent of Code 2015 - Day 1."""

import os
import re


def read_input():
    """Read input file, return string, and drop unexpected characters."""
    base = os.path.abspath(os.path.dirname(__file__))
    file = os.path.join(base, 'input.txt')
    text = open(file).read()
    return re.sub(r'[^()]', '', text)


def steps_to_basement(instructions):
    """Determine number of steps needed to reach the basement."""
    floor = 0
    for step, instruction in enumerate(instructions):
        if instruction == '(':
            floor += 1
        elif instruction == ')':
            floor -= 1
        if floor == -1:
            return step + 1
    raise RuntimeError('Failed to reach basement.')


def main():
    """Main entry point of puzzle solution."""
    instructions = read_input()

    floor = instructions.count('(') - instructions.count(')')
    basement = steps_to_basement(instructions)

    print('Part One: {}'.format(floor))
    print('Part Two: {}'.format(basement))


if __name__ == '__main__':
    main()
