// Advent of Code 2015 - Day 1

actor FloorTracker
  var _basement: I64 = 0
  var _floor: I64 = 0
  var _position: I64 = 0

  fun ref _step(increment: I64) =>
    _floor = _floor + increment
    _position = _position + 1

  be up() =>
    _step(1)

  be down() =>
    _step(-1)
    if (_floor == -1) and (_basement == 0) then
      _basement = _position
    end

  be print_result(env: Env) =>
    env.out.print("Part One: " + _floor.string())
    env.out.print("Part Two: " + _basement.string())

class DirectionsParser is StdinNotify
  let _env: Env
  let _tracker: FloorTracker = FloorTracker

  new iso create(env: Env) =>
    _env = env

  fun ref apply(data: Array[U8] iso) =>
    let data' = consume val data

    for c in data'.values() do
      match c
      | '(' => _tracker.up()
      | ')' => _tracker.down()
      end
    end

  fun ref dispose() =>
    _tracker.print_result(_env)

actor Main
  new create(env: Env) =>
    env.input(DirectionsParser(env))
