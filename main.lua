-- main.lua
-- Maze game: guide a turtle to the destination!
-- Direct control variant: run "maze"

require("constants")
require("levels")
require("turtle")
require("grid")
require("drawing")
require("anim")

sfx = compy.audio

-- Game State

GS = {
  init = false,
  grid = nil,
  goals = {},
  level = 1,
}

-- Parse a maze string-grid for turtle start and goals

function parseCell(ch, c, r)
  if DIR_DELTA[ch] then
    turtleReset(c, r, ch)
  elseif ch == "*" then
    table.insert(GS.goals, {
      col = c, row = r, radius = 1,
    })
  end
end

function parseMaze(level_data)
  GS.grid = level_data
  GS.goals = {}
  for r, row in ipairs(level_data) do
    for c = 1, #row do
      parseCell(row:sub(c, c), c, r)
    end
  end
end

-- Level management

function resetLevel()
  parseMaze(LEVELS[GS.level])
  initGrid(#GS.grid, #(GS.grid[1]))
end

function nextLevel()
  if GS.level < #LEVELS then
    GS.level = GS.level + 1
    resetLevel()
  else
    love.event.quit()
  end
end

function checkGoal()
  for _, g in ipairs(GS.goals) do
    if g.col == turtle.col and g.row == turtle.row then
      startAnim("win", ANIM.win_time)
      turtle.anim.goal = g
      sfx.win()
      return
    end
  end
end

ANIM_FINISHERS.win = nextLevel

function ensureInit()
  if not GS.init then
    resetLevel()
    GS.init = true
  end
end

-- Main loop

function love.update(dt)
  ensureInit()
  updateGoalPulse(dt)
  updateAnim(dt)
end

function love.draw()
  if GS.init then
    drawScene()
  end
end

function love.keypressed(k)
  if k == "escape" then
    resetLevel()
  elseif processKey(k) then
    sfx.ping()
  end
end

function love.resize()
  if GS.init then
    initGrid(GRID.rows, GRID.cols)
  end
end
