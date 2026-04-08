-- turtle.lua
-- Turtle state, direction tables, command queue.

-- Movement deltas for each compass direction

DIR_DELTA = {
  N = { x = 0, y = -1 },
  S = { x = 0, y = 1 },
  W = { x = -1, y = 0 },
  E = { x = 1, y = 0 },
}

-- Angle for each compass direction (for drawing)

DIR_ANGLES = {
  N = 0,
  E = math.pi / 2,
  S = math.pi,
  W = -math.pi / 2,
}

-- Turning tables

TURN_RIGHT = { N = "E", E = "S", S = "W", W = "N" }
TURN_LEFT = { N = "W", W = "S", S = "E", E = "N" }
OPPOSITE_DIR = { N = "S", S = "N", E = "W", W = "E" }

-- All valid commands

VALID_CMD = {
  N=1, S=1, E=1, W=1, L=1, R=1, F=1, B=1,
}

-- Turtle state

turtle = {
  col = 1,
  row = 1,
  dir = "N",
  queue = { },
  anim = nil,
  traces = { },
  color = nil,
}

function turtleReset(col, row, dir)
  turtle.col = col
  turtle.row = row
  turtle.dir = dir
  turtle.queue = { }
  turtle.anim = nil
  turtle.traces = { }
  turtle.color = nil
end

-- Accept a keypress into the queue

function processKey(k)
  local cmd = string.upper(k)
  if VALID_CMD[cmd] then
    table.insert(turtle.queue, cmd)
    return true
  end
  return false
end

-- Pop next command from queue

function dequeue()
  return table.remove(turtle.queue, 1)
end

-- Animation state

function startAnim(kind, duration)
  turtle.anim = {
    kind = kind,
    time = 0,
    duration = duration,
    from_col = turtle.col,
    from_row = turtle.row,
    from_dir = turtle.dir,
  }
end

function animProgress()
  return turtle.anim.time / turtle.anim.duration
end
