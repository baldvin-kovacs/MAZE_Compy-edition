-- anim.lua
-- Animation state machine: turn, move, bump, fail, win.
-- Supports absolute (N/S/E/W) and relative (L/R/F/B) commands.

-- Resolve a command to a move direction (or nil for turns)

function resolveCmd(cmd)
  if DIR_DELTA[cmd] then return cmd end
  if cmd == "F" then return turtle.dir end
  if cmd == "B" then return OPPOSITE_DIR[turtle.dir] end
  return nil
end

-- Compute target position

function moveTarget(dir)
  local d = DIR_DELTA[dir]
  return turtle.col + d.x, turtle.row + d.y
end

-- Start a turn animation

function startTurn(cmd)
  startAnim("turn", ANIM.turn_time)
  if cmd == "R" then
    turtle.anim.target_dir = TURN_RIGHT[turtle.dir]
  else
    turtle.anim.target_dir = TURN_LEFT[turtle.dir]
  end
end

-- Start a move (bump if wall)

function startBump(dir)
  local t = ANIM.move_time * ANIM.bump_frac
  startAnim("bump", t)
  turtle.anim.move_dir = dir
end

function startMove(dir, is_backward)
  local tc, tr = moveTarget(dir)
  if isWall(tc, tr) then
    startBump(dir)
    return
  end
  startAnim("move", ANIM.move_time)
  turtle.anim.target_col = tc
  turtle.anim.target_row = tr
  turtle.anim.move_dir = dir
  turtle.anim.no_trail = is_backward
end

-- Animation finishers

ANIM_FINISHERS = { }

function ANIM_FINISHERS.turn(a)
  turtle.dir = a.target_dir
end

function ANIM_FINISHERS.move(a)
  turtle.col = a.target_col
  turtle.row = a.target_row
  if not a.no_trail then
    turtle.dir = a.move_dir
  end
  if not a.no_trail then
    table.insert(turtle.traces, {
      c1 = a.from_col, r1 = a.from_row,
      c2 = a.target_col, r2 = a.target_row,
    })
  end
  checkGoal()
end

function ANIM_FINISHERS.bump(a)
  turtle.color = Color.red
  sfx.lose()
  startAnim("fail", ANIM.fail_pause)
  turtle.anim.move_dir = a.move_dir
end

ANIM_FINISHERS.fail = resetLevel

function finishAnim()
  local a = turtle.anim
  turtle.anim = nil
  ANIM_FINISHERS[a.kind](a)
end

-- Dequeue and execute the next command

function executeNext()
  local cmd = dequeue()
  if not cmd then return end
  if cmd == "L" or cmd == "R" then
    startTurn(cmd)
    return
  end
  local dir = resolveCmd(cmd)
  if dir then
    startMove(dir, cmd == "B")
  end
end

-- Advance the current animation by dt

function advanceAnim(dt)
  turtle.anim.time = turtle.anim.time + dt
  if turtle.anim.kind == "win" then
    turtle.anim.goal.radius = 1 - animProgress()
  end
  if turtle.anim.duration <= turtle.anim.time then
    finishAnim()
  end
end

-- Per-frame animation update

function updateAnim(dt)
  if not turtle.anim then
    executeNext()
  end
  if turtle.anim then
    advanceAnim(dt)
  end
end
