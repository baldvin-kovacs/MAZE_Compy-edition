-- grid.lua
-- Grid geometry: cell sizing, coordinate conversion, collision.

GRID = {
  cell = 0,
  offset_x = 0,
  offset_y = 0,
  rows = 0,
  cols = 0,
  scale = 0,
  bump_dist = 0,
  trace_r = 0,
}

function initGrid(rows, cols)
  GRID.rows = rows
  GRID.cols = cols
  local w, h = gfx.getDimensions()
  GRID.cell = math.min(w / cols, h / rows)
  GRID.offset_x = (w - GRID.cell * cols) / 2
  GRID.offset_y = (h - GRID.cell * rows) / 2
  local ff = TURTLE.fit_factor
  GRID.scale = GRID.cell / (TURTLE.body_yr * ff)
  local full = TURTLE.body_yr + TURTLE.head_r
  GRID.bump_dist = GRID.cell / 2 - full * GRID.scale
  GRID.trace_r = TURTLE.head_r * GRID.scale
end

function cellTopLeft(col, row)
  local x = GRID.offset_x + (col - 1) * GRID.cell
  local y = GRID.offset_y + (row - 1) * GRID.cell
  return x, y
end

function cellCenter(col, row)
  local x, y = cellTopLeft(col, row)
  local half = GRID.cell / 2
  return x + half, y + half
end

function isWall(col, row)
  if row < 1 or GRID.rows < row then
    return true
  end
  if col < 1 or GRID.cols < col then
    return true
  end
  return GS.grid[row]:sub(col, col) == "#"
end
