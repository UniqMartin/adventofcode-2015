"""Advent of Code 2015 - Day 13."""

import itertools
import os
import re


def read_input():
    """Read input file and split into individual lines returned as a list."""
    base = os.path.abspath(os.path.dirname(__file__))
    file = os.path.join(base, 'input.txt')
    return open(file).read().splitlines()


class AmityMap:
    """Map of people and their mutual amities (not symmetric)."""

    # Regular expression for parsing amity pairs from the input file.
    SEATING_REGEXP = re.compile(r'^(?P<foo>.+) would (?P<sign>gain|lose) '
                                r'(?P<happiness>\d+) happiness units by '
                                r'sitting next to (?P<bar>.+)\.$')

    @classmethod
    def from_lines(cls, lines):
        """Initialize a map from lines read from the input file."""
        amity_map = cls()
        for line in lines:
            match = cls.SEATING_REGEXP.search(line)
            happiness = int(match.group('happiness'))
            if match.group('sign') == 'lose':
                happiness *= -1
            amity_map.add_amity_pair(match.group('foo'),
                                     match.group('bar'),
                                     happiness)

        return amity_map

    def __init__(self):
        """Initialize an empty map."""
        self.names = {}
        self.amity = {}

    def add_amity_pair(self, foo, bar, happiness):
        """Add a pair of people and their (directed) amity to the map."""
        foo_id = self.names.setdefault(foo, len(self.names))
        bar_id = self.names.setdefault(bar, len(self.names))
        self.amity[(foo_id, bar_id)] = happiness

    def add_self(self):
        """Add a neutral (in terms of amity) self to the map."""
        num_others = len(self.names)
        self_id = self.names.setdefault('Self', num_others)
        for other_id in range(num_others):
            self.amity[(self_id, other_id)] = 0
            self.amity[(other_id, self_id)] = 0

        # Simplify chaining method calls.
        return self

    def arrangements(self):
        """Yield all possible seating arrangements."""
        for name_list in itertools.permutations(self.names.values()):
            yield name_list, (*name_list[1:], name_list[0])

    def arrangement_happinesses(self):
        """Yield happinesses for all possible seating arrangements."""
        for pair in self.arrangements():
            happiness = 0
            for foo, bar in zip(*pair):
                happiness += self.amity[(foo, bar)] + self.amity[(bar, foo)]
            yield happiness


def main():
    """Main entry point of puzzle solution."""
    amity_map = AmityMap.from_lines(read_input())

    part_one = max(amity_map.arrangement_happinesses())
    part_two = max(amity_map.add_self().arrangement_happinesses())

    print('Part One: {}'.format(part_one))
    print('Part Two: {}'.format(part_two))


if __name__ == '__main__':
    main()
