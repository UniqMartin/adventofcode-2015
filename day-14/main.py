"""Advent of Code 2015 - Day 14."""

import itertools
import os
import re


def read_input():
    """Read input file and split into individual lines returned as a list."""
    base = os.path.abspath(os.path.dirname(__file__))
    file = os.path.join(base, 'input.txt')
    return open(file).read().splitlines()


class Reindeer:
    """Reindeer with a name and various racing properties."""

    def __init__(self, name, speed, race_time, rest_time):
        """Initialize reindeer with its name and other properties."""
        self.name = name
        self.speed = speed
        self.race_time = race_time
        self.rest_time = rest_time

    def race(self):
        """Yield traveled distances at discrete times for an infinite race."""
        lap_time = self.race_time + self.rest_time
        time = 0
        distance = 0
        while True:
            yield distance
            if (time % lap_time) < self.race_time:
                distance += self.speed
            time += 1


class ReindeerRace:
    """Reindeer race with a stable and various racing options."""

    # Regular expression for parsing reindeer specs from the input file.
    REINDEER_REGEXP = re.compile(r'^(?P<name>.+) can fly (?P<speed>\d+) km/s '
                                 r'for (?P<race_time>\d+) seconds, but then '
                                 r'must rest for (?P<rest_time>\d+) '
                                 r'seconds\.$')

    @classmethod
    def from_lines(cls, lines):
        """Initialize a reindeer race from lines from the input file."""
        race = cls()
        for line in lines:
            match = cls.REINDEER_REGEXP.search(line)
            reindeer = Reindeer(match.group('name'),
                                int(match.group('speed')),
                                int(match.group('race_time')),
                                int(match.group('rest_time')))
            race.stable.append(reindeer)

        return race

    def __init__(self):
        """Initialize a reindeer race with an empty stable."""
        self.stable = []

    def winning_distance_after(self, target_time):
        """Determine the winning distance of the best reindeer of a race."""
        def distance_after_race(reindeer):
            """Determine distance traveled by reindeer after a given time."""
            return next(itertools.islice(reindeer.race(), target_time, None))

        return max(map(distance_after_race, self.stable))

    def winning_points_after(self, target_time):
        """Determine the winning points of the best reindeer of a race."""
        def distances_during_race(reindeer):
            """Yield distances traveled by reindeer during a finite race."""
            return itertools.islice(reindeer.race(), 1, target_time + 1)

        points = [0] * len(self.stable)
        for distances in zip(*map(distances_during_race, self.stable)):
            leading_distance = max(distances)
            for index, distance in enumerate(distances):
                if distance == leading_distance:
                    points[index] += 1

        return max(points)


def main():
    """Main entry point of puzzle solution."""
    reindeer_race = ReindeerRace.from_lines(read_input())

    part_one = reindeer_race.winning_distance_after(2503)
    part_two = reindeer_race.winning_points_after(2503)

    print('Part One: {}'.format(part_one))
    print('Part Two: {}'.format(part_two))


if __name__ == '__main__':
    main()
