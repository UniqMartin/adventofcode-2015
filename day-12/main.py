"""Advent of Code 2015 - Day 12."""

import json
import numbers
from pathlib import Path


def read_input():
    """Read input file."""
    return Path(__file__).with_name('input.json').read_text()


def traverse_json(data, filter=None):
    """Recursively traverse JSON structure yielding all its elements."""
    if filter and filter(data):
        return
    yield data

    # Handle nested structures like dicts/lists and yield their values, too.
    if isinstance(data, dict):
        for item in data.values():
            yield from traverse_json(item, filter=filter)
    elif isinstance(data, list):
        for item in data:
            yield from traverse_json(item, filter=filter)


def is_number(item):
    """Check if the item is a number."""
    return isinstance(item, numbers.Number)


def is_red_dict(item):
    """Check if the item is a dict that contains a red value."""
    return isinstance(item, dict) and 'red' in item.values()


def main():
    """Main entry point of puzzle solution."""
    data = json.loads(read_input())

    part_one = sum(filter(is_number, traverse_json(data)))
    part_two = sum(filter(is_number, traverse_json(data, filter=is_red_dict)))

    print('Part One: {}'.format(part_one))
    print('Part Two: {}'.format(part_two))


if __name__ == '__main__':
    main()
