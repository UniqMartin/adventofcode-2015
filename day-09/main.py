"""Advent of Code 2015 - Day 9."""

import itertools
import re
from pathlib import Path


def read_input():
    """Read input file and split into individual lines returned as a list."""
    return Path(__file__).with_name('input.txt').read_text().splitlines()


class CityMap:
    """Map of cities and their mutual distances."""

    # Regular expression for parsing city pair distances from the input file.
    CITY_PAIR_REGEXP = re.compile(r'^(.+) to (.+) = (\d+)$')

    @classmethod
    def from_lines(cls, lines):
        """Initialize a map from lines read from the input file."""
        city_map = cls()
        for line in lines:
            source, target, dist = cls.CITY_PAIR_REGEXP.search(line).groups()
            city_map.add_city_pair(source, target, int(dist))

        return city_map

    def __init__(self):
        """Initialize an empty map."""
        self.city = {}
        self.link = {}

    def add_city_pair(self, source, target, dist):
        """Add a pair of cities and their mutual distance to the map."""
        source_id = self.city.setdefault(source, len(self.city))
        target_id = self.city.setdefault(target, len(self.city))
        self.link[(source_id, target_id)] = dist
        self.link[(target_id, source_id)] = dist

    def routes(self):
        """Yield all possible routes between cities."""
        for city_list in itertools.permutations(self.city.values()):
            yield city_list[:-1], city_list[1:]

    def route_lengths(self):
        """Yield the lengths of all possible routes between cities."""
        for sources, targets in self.routes():
            yield sum(self.link[pair] for pair in zip(sources, targets))


def main():
    """Main entry point of puzzle solution."""
    route_lengths = list(CityMap.from_lines(read_input()).route_lengths())

    part_one = min(route_lengths)
    part_two = max(route_lengths)

    print('Part One: {}'.format(part_one))
    print('Part Two: {}'.format(part_two))


if __name__ == '__main__':
    main()
