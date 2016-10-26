"""Advent of Code 2015 - Day 10."""

import itertools


def look_and_say(seed):
    """Yield elements of the look-and-say sequence starting with the seed."""
    yield seed

    element = seed
    while True:
        chunks = []
        for digit, run in itertools.groupby(element):
            count = sum(1 for _ in run)
            chunks.append(str(count) + digit)
        element = ''.join(chunks)
        yield element


def main():
    """Main entry point of puzzle solution."""
    INPUT_SEED = '3113322113'

    look_and_say_40 = itertools.islice(look_and_say(INPUT_SEED), 40, None, 10)
    for part, element in zip(['One', 'Two'], look_and_say_40):
        print('Part {}: {}'.format(part, len(element)))


if __name__ == '__main__':
    main()
