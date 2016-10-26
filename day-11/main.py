"""Advent of Code 2015 - Day 11."""

import itertools
import re
import string


def rule_1(password):
    """Check if a password adheres to the 1st password rule."""
    characters = list(password)
    for index in range(len(characters) - 2):
        a, b, c = characters[index:index + 3]
        if ord(a) + 1 == ord(b) == ord(c) - 1:
            return True
    return False


# 2nd password rule: Forbidden characters.
RULE_2 = re.compile(r'[iol]')

# 3rd password rule: Two non-overlapping different pairs.
RULE_3 = re.compile(r'([a-z])\1.*(?!\1)([a-z])\2')


def valid_password(password):
    """Check if a password is valid according to all given password rules."""
    return (not RULE_2.search(password) and
            RULE_3.search(password) and
            rule_1(password))


def string_range(start, stop=None, symbols=string.ascii_lowercase):
    """Yield lexicographically increasing fixed-length strings."""
    item_sym = list(start)
    if stop is None:
        stop = symbols[-1] * len(start)
    last_symbol = len(symbols) - 1

    item_int = list(map(symbols.index, item_sym))
    stop_int = list(map(symbols.index, stop))

    while item_int < stop_int:
        yield ''.join(item_sym)

        # Handle overflow in least-significant symbols.
        index = -1
        while item_int[index] == last_symbol:
            item_int[index] = 0
            item_sym[index] = symbols[0]
            index -= 1

        # Advance right-most symbol that will not overflow.
        item_int[index] += 1
        item_sym[index] = symbols[item_int[index]]


def main():
    """Main entry point of puzzle solution."""
    INPUT_PASSWORD = 'hepxcrrq'

    # Make sure to skip over input password, even if it would be valid.
    next_passwords = itertools.islice(string_range(INPUT_PASSWORD), 1, None)
    good_passwords = filter(valid_password, next_passwords)
    for part, password in zip(['One', 'Two'], good_passwords):
        print('Part {}: {}'.format(part, password))


if __name__ == '__main__':
    main()
