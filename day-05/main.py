"""Advent of Code 2015 - Day 5."""

import os
import re


def read_input():
    """Read input file and split into individual lines returned as a list."""
    base = os.path.abspath(os.path.dirname(__file__))
    file = os.path.join(base, 'input.txt')
    return open(file).read().splitlines()


def count_if(predicate, iterable):
    """Count the number of items of an iterable that satisfy predicate."""
    return sum(1 for item in iterable if predicate(item))


class RulesOne:
    """Helper for checking words against the 1st set of niceness rules."""

    # 1st rule: At least three vowels.
    _RULE_1 = re.compile(r'([aeiou].*){3,}')

    # 2nd rule: At least one letter twice in a row.
    _RULE_2 = re.compile(r'(.)\1')

    # 3rd rule: None of the listed letter pairs.
    _RULE_3 = re.compile(r'(ab|cd|pq|xy)')

    @classmethod
    def is_nice(cls, word):
        """Check if a word is nice according to the 1st set of rules."""
        return (cls._RULE_1.search(word) and
                cls._RULE_2.search(word) and
                not cls._RULE_3.search(word))


class RulesTwo:
    """Helper for checking words against the 2nd set of niceness rules."""

    # 1st rule: Two consecutive letters at least twice (no overlap).
    _RULE_1 = re.compile(r'(..).*\1')

    # 2nd rule: Repeated letter with exactly one letter between them.
    _RULE_2 = re.compile(r'(.).\1')

    @classmethod
    def is_nice(cls, word):
        """Check if a word is nice according to the 2nd set of rules."""
        return cls._RULE_1.search(word) and cls._RULE_2.search(word)


def main():
    """Main entry point of puzzle solution."""
    lines = read_input()

    part_one = count_if(RulesOne.is_nice, lines)
    part_two = count_if(RulesTwo.is_nice, lines)

    print('Part One: {}'.format(part_one))
    print('Part Two: {}'.format(part_two))


if __name__ == '__main__':
    main()
