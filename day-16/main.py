"""Advent of Code 2015 - Day 16."""

import operator
import re
from pathlib import Path


def read_input():
    """Read input file and split into individual lines returned as a list."""
    return Path(__file__).with_name('input.txt').read_text().splitlines()


class Aunt:
    """Aunt identified by a number and described by various information."""

    # Regular expression for extracting number and description of aunt.
    AUNT_REGEXP = re.compile(r'^Sue (\d+): (.*)$')

    # Regular expression for further processing an aunt description.
    INFO_REGEXP = re.compile(r'(\w+): (\d+)')

    @classmethod
    def from_line(cls, line):
        """Initialize an aunt from a line from the input file."""
        number, infos = cls.AUNT_REGEXP.search(line).groups()
        return cls(int(number),
                   [(k, int(v)) for k, v in cls.INFO_REGEXP.findall(infos)])

    def __init__(self, number, infos):
        """Initialize an aunt with its number and a description."""
        self.number = number
        self.infos = infos

    def match(self, wanted_value, wanted_relop):
        """Check if the aunt matches the given description."""
        for key, value in self.infos:
            relop = wanted_relop.get(key, operator.eq)
            if not relop(value, wanted_value[key]):
                return False
        return True


def find_aunt(aunts, wanted_value, wanted_relop={}):
    """Find aunt that uniquely matches the given description."""
    matcher = operator.methodcaller('match', wanted_value, wanted_relop)
    matched = list(filter(matcher, aunts))
    if len(matched) == 1:
        return matched[0]
    raise RuntimeError('Failed to find uniquely matching aunt.')


def main():
    """Main entry point of puzzle solution."""
    WANTED_VALUE = {
        'children': 3,
        'cats': 7,
        'samoyeds': 2,
        'pomeranians': 3,
        'akitas': 0,
        'vizslas': 0,
        'goldfish': 5,
        'trees': 3,
        'cars': 2,
        'perfumes': 1,
    }

    WANTED_RELOP = {
        'cats': operator.gt,
        'trees': operator.gt,
        'pomeranians': operator.lt,
        'goldfish': operator.lt,
    }

    aunts = [Aunt.from_line(line) for line in read_input()]

    part_one = find_aunt(aunts, WANTED_VALUE).number
    part_two = find_aunt(aunts, WANTED_VALUE, WANTED_RELOP).number

    print('Part One: {}'.format(part_one))
    print('Part Two: {}'.format(part_two))


if __name__ == '__main__':
    main()
