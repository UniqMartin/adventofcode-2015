"""Advent of Code 2015 - Day 2."""

from pathlib import Path


def read_input():
    """Read input file and split into individual lines returned as a list."""
    return Path(__file__).with_name('input.txt').read_text().splitlines()


def one_paper(l, w, h):
    """Compute needed wrapping paper for one present.

    Arguments l, w, and h are expected to be sorted for a correct result.
    """
    area = 2 * (l * w + l * h + w * h)
    slack = l * w
    return area + slack


def one_ribbon(l, w, h):
    """Compute needed ribbon for one present.

    Arguments l, w, and h are expected to be sorted for a correct result.
    """
    return 2 * (l + w) + l * w * h


def main():
    """Main entry point of puzzle solution."""
    lines = read_input()

    paper = 0
    ribbon = 0

    for line in lines:
        dims = sorted(map(int, line.split('x')))
        paper += one_paper(*dims)
        ribbon += one_ribbon(*dims)

    print('Part One: {}'.format(paper))
    print('Part Two: {}'.format(ribbon))


if __name__ == '__main__':
    main()
