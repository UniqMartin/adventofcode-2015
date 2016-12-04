"""Advent of Code 2015 - Day 8."""

import re
from pathlib import Path


def read_input():
    """Read input file and split into individual lines returned as a list."""
    return Path(__file__).with_name('input.txt').read_text().splitlines()


def decode_string(string):
    """Decode a string by resolving backslash-escaped characters."""
    return re.sub(r'\\(?:\\|"|x[0-9a-f]{2})', '*', string[1:-1])


def encode_string(string):
    """Encode a string by escaping quotation marks and backslashes."""
    return '"{}"'.format(re.sub(r'["\\]', r'\\\0', string))


def main():
    """Main entry point of puzzle solution."""
    lines = read_input()

    size_in_file = sum(len(s) for s in lines)
    size_decoded = sum(len(decode_string(s)) for s in lines)
    size_encoded = sum(len(encode_string(s)) for s in lines)

    print('Part One: {}'.format(size_in_file - size_decoded))
    print('Part Two: {}'.format(size_encoded - size_in_file))


if __name__ == '__main__':
    main()
