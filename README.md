# Advent of Code 2015

Martin's solutions for [Advent of Code](http://adventofcode.com/) 2015.

## Usage

To run individual solutions, where `NN` is the zero-padded number of the day:

- [Pony](http://www.ponylang.org/): `bin-pony/day-NN < day-NN/input.txt`
	- Build beforehand with `make bin-pony/day-NN` or `make build-pony`.
- Python: `python3 day-NN/main.py`
- Ruby: `ruby day-NN/main.rb`

All output is standardized to look something like this:

```
Part One: <solution for part one>
Part Two: <solution for part two>
```

## Notes

- Output obviously depends on the user-specific input. This input is either in a file named `input.txt` or somewhere at the top of the main code file.
- Pony code was tested with Pony 0.2.1.
- Python code was tested with Python 3.5.2.
- Ruby code was tested with Ruby 2.0.

## License

Code is under the [BSD 2 Clause (NetBSD) license](LICENSE.txt).
