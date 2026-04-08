-- drawing.lua
-- All rendering code: maze, traces, turtle.

gfx = love.graphics

-- Maze drawing

function drawWalls()
  local w, h = gfx.getDimensions()
  gfx.setColor(Color[Color.blue + Color.bright])
  gfx.rectangle("fill", 0, 0, w, h)
end

function drawCells()
  gfx.setColor(Color[Color.white])
  for r, row in ipairs(GS.grid) do
    for c = 1, #row do
      if row:sub(c, c) ~= "#" then
        local x, y = cellTopLeft(c, r)
        gfx.rectangle("fill", x, y, GRID.cell, GRID.cell)
      end
    end
  end
end

GOAL_TIME = 0

function updateGoalPulse(dt)
  GOAL_TIME = GOAL_TIME + dt
end

function goalPulseScale()
  local t = GOAL_TIME / ANIM.goal_pulse
  local phase = math.sin(t * 2 * math.pi)
  return 0.85 + 0.15 * phase
end

function drawGoals()
  gfx.setColor(Color[Color.red])
  local pulse = goalPulseScale()
  for _, g in ipairs(GS.goals) do
    local x, y = cellCenter(g.col, g.row)
    local r = (GRID.cell / 2) * g.radius * pulse
    gfx.circle("fill", x, y, r)
  end
end

-- Traces: cyan lines showing the turtle's path

function drawActiveTrace()
  local a = turtle.anim
  if not a or a.kind ~= "move" then return end
  if a.no_trail then return end
  local x1, y1 = cellCenter(a.from_col, a.from_row)
  local x2, y2 = currentPos()
  gfx.line(x1, y1, x2, y2)
end

function drawTraces()
  gfx.setColor(Color[Color.cyan])
  gfx.setLineWidth(GRID.trace_r * 2)
  for _, t in ipairs(turtle.traces) do
    local x1, y1 = cellCenter(t.c1, t.r1)
    local x2, y2 = cellCenter(t.c2, t.r2)
    gfx.line(x1, y1, x2, y2)
    gfx.circle("fill", x1, y1, GRID.trace_r)
    gfx.circle("fill", x2, y2, GRID.trace_r)
  end
  drawActiveTrace()
  gfx.setLineWidth(1)
end

-- Turtle body parts

function drawLeg(scale, sx, sy)
  local xr = TURTLE.body_xr * scale
  local lxr = TURTLE.leg_xr * scale
  local lyr = TURTLE.leg_yr * scale
  local yr = TURTLE.body_yr * scale
  gfx.push("all")
  gfx.translate(sx * xr, sy * (yr / 2 + lxr))
  gfx.rotate(sx * sy * TURTLE.leg_angle)
  gfx.ellipse("fill", 0, 0, lxr, lyr)
  gfx.pop()
end

function drawLegs(scale)
  drawLeg(scale, -1, -1)
  drawLeg(scale, 1, -1)
  drawLeg(scale, -1, 1)
  drawLeg(scale, 1, 1)
end

function drawBody(scale)
  local xr = TURTLE.body_xr * scale
  local yr = TURTLE.body_yr * scale
  local hr = TURTLE.head_r * scale
  local neck = TURTLE.neck * scale
  gfx.ellipse("fill", 0, 0, xr, yr)
  gfx.circle("fill", 0, (-yr - hr) + neck, hr)
end

function drawTurtleAt(x, y, angle, scale)
  local body_c = turtle.color or Color.green
  local limb_c = body_c + Color.bright
  gfx.push("all")
  gfx.translate(x, y)
  gfx.rotate(angle)
  gfx.setColor(Color[limb_c])
  drawLegs(scale)
  gfx.setColor(Color[body_c])
  drawBody(scale)
  gfx.pop()
end

-- Turtle position during animation

function animMovePos()
  local a = turtle.anim
  local p = animProgress()
  local x1, y1 = cellCenter(a.from_col, a.from_row)
  local x2, y2 = cellCenter(a.target_col, a.target_row)
  return x1 + (x2 - x1) * p, y1 + (y2 - y1) * p
end

function bumpPos(p)
  local a = turtle.anim
  local d = DIR_DELTA[a.move_dir]
  local cx, cy = cellCenter(turtle.col, turtle.row)
  return cx + d.x * GRID.bump_dist * p,
         cy + d.y * GRID.bump_dist * p
end

-- Smoothly rotate between two directions

function lerpAngle(from_dir, to_dir, t)
  local from = DIR_ANGLES[from_dir]
  local to = DIR_ANGLES[to_dir]
  local diff = to - from
  if math.pi < diff then
    diff = diff - 2 * math.pi
  elseif diff < -math.pi then
    diff = diff + 2 * math.pi
  end
  return from + diff * t
end

-- Current turtle position for this frame

function currentPos()
  local a = turtle.anim
  if a and a.kind == "move" then
    return animMovePos()
  elseif a and a.kind == "bump" then
    return bumpPos(animProgress())
  elseif a and a.kind == "fail" then
    return bumpPos(1)
  end
  return cellCenter(turtle.col, turtle.row)
end

-- Current turtle angle for this frame

function currentAngle()
  local a = turtle.anim
  if a and a.kind == "turn" then
    return lerpAngle(a.from_dir, a.target_dir, animProgress())
  elseif a and a.kind == "move" and not a.no_trail then
    return lerpAngle(a.from_dir, a.move_dir, animProgress())
  end
  return DIR_ANGLES[turtle.dir]
end

-- Level indicator in the corner

function drawLevelIndicator()
  gfx.setColor(0.5, 0.5, 0.5, 0.6)
  local font = gfx.getFont()
  local text = "Maze " .. GS.level
  gfx.print(text, 6, 4)
end

-- Legend in the bottom-right corner

LEGEND = ""

function loadLegend()
  LEGEND = readfile("legend.txt") or ""
end

function drawLegend()
  if LEGEND == "" then return end
  local w, h = gfx.getDimensions()
  local font = gfx.getFont()
  local fh = font:getHeight()
  local _, n = LEGEND:gsub("\n", "")
  local th = fh * (n + 1)
  gfx.setColor(0.3, 0.3, 0.3, 0.5)
  gfx.print(LEGEND, w - font:getWidth(LEGEND) - fh, h - th - fh)
end

-- Draw the complete scene

function drawScene()
  drawWalls()
  drawCells()
  drawGoals()
  drawTraces()
  local x, y = currentPos()
  local angle = currentAngle()
  drawTurtleAt(x, y, angle, GRID.scale)
  drawLevelIndicator()
  drawLegend()
end
