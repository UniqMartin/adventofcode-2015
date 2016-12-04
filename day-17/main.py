"""Advent of Code 2015 - Day 17."""

import itertools
from pathlib import Path


def read_input():
    """Read input file and return as a list of integers (one per line)."""
    lines = Path(__file__).with_name('input.txt').read_text().splitlines()
    return [int(line) for line in lines]


def powerset(x):
    """Yield elements of the power set of the given list."""
    return itertools.chain.from_iterable(itertools.combinations(x, r)
                                         for r in range(len(x) + 1))


def precompute_half(containers):
    """Prepare all possible half container combinations, keyed by volume."""
    sums = {}
    for sizes in powerset(containers):
        sums.setdefault(sum(sizes), []).append(sizes)
    return sums


def precompute_sums(containers):
    """Prepare all possible left/right container combinations by volume."""
    if len(containers) < 2:
        raise RuntimeError('List of containers is too short.')

    middle = len(containers) // 2
    l_half = precompute_half(containers[:middle])
    r_half = precompute_half(containers[middle:])
    return l_half, r_half


def enum_variants(containers, target_volume):
    """Yield container combinations that match the target volume.

    Use a divide-and-conquer approach by computing the volumes of all possible
    container combinations for the left and right side of the container list.
    Then use that to find pairs whose summed volume matches the target volume.
    """
    l_half, r_half = precompute_sums(containers)

    for l_volume, l_sizes in l_half.items():
        r_volume = target_volume - l_volume
        if (r_volume < 0) or (r_volume not in r_half):
            continue
        r_sizes = r_half[r_volume]
        for l_size, r_size in itertools.product(l_sizes, r_sizes):
            yield l_size + r_size


def enum_shortest(variants):
    """Yield container combinations of minimum length."""
    optimal_length = len(min(variants, key=len))
    return (variant for variant in variants if len(variant) == optimal_length)


def main():
    """Main entry point of puzzle solution."""
    EGGNOG_VOLUME = 150

    containers = read_input()

    part_one = list(enum_variants(containers, EGGNOG_VOLUME))
    part_two = list(enum_shortest(part_one))

    print('Part One: {}'.format(len(part_one)))
    print('Part Two: {}'.format(len(part_two)))


if __name__ == '__main__':
    main()
