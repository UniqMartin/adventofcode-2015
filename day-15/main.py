"""Advent of Code 2015 - Day 15."""

import itertools
import operator
import re
from pathlib import Path


def read_input():
    """Read input file and split into individual lines returned as a list."""
    return Path(__file__).with_name('input.txt').read_text().splitlines()


def dotproduct(lhs, rhs):
    """Compute the dot product of two vectors."""
    return sum(map(operator.mul, lhs, rhs))


def transposed(matrix):
    """Transpose a matrix (list of nested lists of equal length)."""
    return [list(column) for column in zip(*matrix)]


class Ingredient:
    """Ingredient with name, calories, and other properties."""

    def __init__(self, name, properties):
        """Initialize ingredient with its name and properties."""
        self.name = name
        self.calories = properties.pop('calories')
        self.properties = properties


class Recipe:
    """Recipe with ingredients and methods to optimally balance those."""

    # Regular expression for extracting name and properties from ingredient.
    INGREDIENT_REGEXP = re.compile(r'^(?P<name>\w+): (?P<properties>.*)$')

    # Regular expression for splitting properties into name-value pairs.
    PROPERTY_REGEXP = re.compile(r'(\w+) ([+-]?\d+)')

    @classmethod
    def from_lines(cls, lines):
        """Initialize a recipe from lines from the input file."""
        recipe = cls()
        for line in lines:
            match = cls.INGREDIENT_REGEXP.search(line)
            properties = cls.PROPERTY_REGEXP.findall(match.group('properties'))
            recipe.add_ingredient(match.group('name'),
                                  dict((k, int(v)) for k, v in properties))

        return recipe

    def __init__(self):
        """Initialize an empty recipe."""
        self.ingredients = []

    def add_ingredient(self, name, properties):
        """Add a named ingredient with its properties to the recipe."""
        self.ingredients.append(Ingredient(name, properties))

    def best_score(self, **kwargs):
        """Best score of all valid combinations of ingredients."""
        return max(self.__all_scores(**kwargs), default=None)

    def __all_scores(self, teaspoons=None, calories=None):
        """Yield scores for valid combinations of ingredients."""
        calo_weights, prop_weights = self.__setup_weights()

        ranges = [range(teaspoons + 1) for _ in self.ingredients]
        ranges.pop()
        for parts in itertools.product(*ranges):
            # Make sure we only test canonical combinations where the sum of
            # the individual parts adds up to the given number of teaspoons.
            filler = teaspoons - sum(parts)
            if filler < 0:
                continue
            i_spoons = parts + (filler,)

            # If we have a target for the number of calories, check that.
            if calories and dotproduct(i_spoons, calo_weights) != calories:
                continue

            # Yield scores where all contributing factors are positive.
            full_score = 1
            for prop_weight in prop_weights:
                prop_score = dotproduct(i_spoons, prop_weight)
                if prop_score <= 0:
                    break
                full_score *= prop_score
            else:
                yield full_score

    def __setup_weights(self):
        """Set up weighting vector/matrix for calories/properties."""
        prop_names = self.ingredients[0].properties.keys()
        name2value = operator.itemgetter(*prop_names)

        calo_weights = []
        prop_weights = []
        for ingredient in self.ingredients:
            calo_weights.append(ingredient.calories)
            prop_weights.append(name2value(ingredient.properties))

        return calo_weights, transposed(prop_weights)


def main():
    """Main entry point of puzzle solution."""
    NUM_CALORIES = 500
    NUM_TEASPOONS = 100

    recipe = Recipe.from_lines(read_input())

    part_one = recipe.best_score(teaspoons=NUM_TEASPOONS)
    part_two = recipe.best_score(teaspoons=NUM_TEASPOONS,
                                 calories=NUM_CALORIES)

    print('Part One: {}'.format(part_one))
    print('Part Two: {}'.format(part_two))


if __name__ == '__main__':
    main()
