"""Advent of Code 2015 - Day 4."""

import hashlib
import itertools


def md5_with_prefix(input, prefix, start_with=0):
    """Determine first number that generates a hash with the given prefix."""
    md5_input = hashlib.md5(input)

    for number in itertools.count(start_with):
        md5 = md5_input.copy()
        md5.update(str(number).encode('ascii'))
        if md5.hexdigest().startswith(prefix):
            return number


def main():
    """Main entry point of puzzle solution."""
    INPUT_KEY = b'ckczppom'

    magic_one = md5_with_prefix(INPUT_KEY, '0' * 5)
    magic_two = md5_with_prefix(INPUT_KEY, '0' * 6, start_with=magic_one)

    print('Part One: {}'.format(magic_one))
    print('Part Two: {}'.format(magic_two))


if __name__ == '__main__':
    main()
