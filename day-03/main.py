"""Advent of Code 2015 - Day 3."""

import os
import re


def read_input():
    """Read input file, return string, and drop unexpected characters."""
    base = os.path.abspath(os.path.dirname(__file__))
    file = os.path.join(base, 'input.txt')
    text = open(file).read()
    return re.sub(r'[^<>^v]', '', text)


def read_instructions():
    """Convert textual movement instructions to 2D offsets."""
    item_to_offset = {
        '<': (-1, 0),
        '>': (+1, 0),
        '^': (0, -1),
        'v': (0, +1),
    }
    return [item_to_offset[item] for item in read_input()]


def walk(instructions):
    """Determine trail resulting from walking the given instruction."""
    x = 0
    y = 0
    trail = {(x, y)}

    for x_offset, y_offset in instructions:
        x += x_offset
        y += y_offset
        trail.add((x, y))

    return trail


def walk_with_robo_santa(instructions):
    """Split instructions for real/robo Santa and let them walk in parallel."""
    instructions_real_santa = instructions[0::2]
    instructions_robo_santa = instructions[1::2]

    return walk(instructions_real_santa) | walk(instructions_robo_santa)


def main():
    """Main entry point of puzzle solution."""
    instructions = read_instructions()

    part_one = len(walk(instructions))
    part_two = len(walk_with_robo_santa(instructions))

    print('Part One: {}'.format(part_one))
    print('Part Two: {}'.format(part_two))


if __name__ == '__main__':
    main()
