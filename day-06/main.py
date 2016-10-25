"""Advent of Code 2015 - Day 6."""

import os
import re


def read_input():
    """Read input file and split into individual lines returned as a list."""
    base = os.path.abspath(os.path.dirname(__file__))
    file = os.path.join(base, 'input.txt')
    return open(file).read().splitlines()


class Rect(object):
    """Rectangular region represented as a pair of ranges."""

    def __init__(self, x_range, y_range):
        """Initialize a rectangle from a pair of ranges."""
        self.x_range = x_range
        self.y_range = y_range

    def coordinates(self):
        """Yield all integer coordinate pairs covered by the rectangle."""
        for x in self.x_range:
            for y in self.y_range:
                yield x, y


class Command(object):
    """Command used for updating light arrays."""

    # Regular expression for parsing commands from the input file.
    COMMAND_REGEXP = re.compile(r'^(toggle|turn (?:off|on)) '
                                r'(\d+),(\d+) through (\d+),(\d+)$')

    @classmethod
    def parse(cls, line):
        """Parse a command from a line of text read from the input file."""
        action, *rect = cls.COMMAND_REGEXP.search(line).groups()

        x_min, y_min, x_max, y_max = map(int, rect)
        x_range = range(x_min, x_max + 1)
        y_range = range(y_min, y_max + 1)

        return cls(action, Rect(x_range, y_range))

    def __init__(self, action, rect):
        """Initialize command from an action verb and a rectangular region."""
        self.action = action
        self.rect = rect


class LightArray(object):
    """Abstract rectangular light array that can be updated with commands."""

    def __init__(self, width=1000, height=1000):
        """Initialize light array with all elements set to zero."""
        self.matrix = [[0] * height for _ in range(width)]

    def apply_commands(self, commands):
        """Apply a list of commands to update the state of the light array."""
        for command in commands:
            self._apply_command(command)

        return self

    def brightness(self):
        """Compute the total brightness of the light array."""
        return sum(sum(column) for column in self.matrix)

    def _apply_command(self, command):
        """Update the state of the light array per the given command."""
        mapping = self._action_to_mapping(command.action)
        for x, y in command.rect.coordinates():
            self.matrix[x][y] = mapping(self.matrix[x][y])


class BinaryLightArray(LightArray):
    """Light array where elements are either on or off."""

    # Actions and corresponding lambdas for updating the brightness.
    ACTION_TO_MAPPING = {
        'toggle': lambda brightness: 1 - brightness,
        'turn off': lambda _: 0,
        'turn on': lambda _: 1,
    }

    def _action_to_mapping(self, action):
        """Map action to a callable that transforms the brightness."""
        return self.ACTION_TO_MAPPING[action]


class SteppedLightArray(LightArray):
    """Light array with positive integer brightness."""

    # Actions and corresponding lambdas for updating the brightness.
    ACTION_TO_MAPPING = {
        'toggle': lambda brightness: brightness + 2,
        'turn off': lambda brightness: max(brightness - 1, 0),
        'turn on': lambda brightness: brightness + 1,
    }

    def _action_to_mapping(self, action):
        """Map action to a callable that transforms the brightness."""
        return self.ACTION_TO_MAPPING[action]


def main():
    """Main entry point of puzzle solution."""
    commands = [Command.parse(line) for line in read_input()]

    part_one = BinaryLightArray().apply_commands(commands).brightness()
    part_two = SteppedLightArray().apply_commands(commands).brightness()

    print('Part One: {}'.format(part_one))
    print('Part Two: {}'.format(part_two))


if __name__ == '__main__':
    main()
