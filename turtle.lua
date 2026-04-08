-- turtle.lua
-- Turtle state and absolute direction tables.

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

-- Turtle state

turtle = {
  col = 1,
  row = 1,
  dir = "N",
  queue = {},
  anim = nil,
  traces = {},
  color = nil,
}

function turtleReset(col, row, dir)
  turtle.col = col
  turtle.row = row
  turtle.dir = dir
  turtle.queue = {}
  turtle.anim = nil
  turtle.traces = {}
  turtle.color = nil
end

-- Accept a direction keypress into the queue

function processKey(k)
  local cmd = string.upper(k)
  if DIR_DELTA[cmd] then
    table.insert(turtle.queue, cmd)
    return true
  end
  return false
end

-- Pop next command (absolute direction) from queue

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
