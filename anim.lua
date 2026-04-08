-- anim.lua
-- Animation state machine: start, advance, finish.

-- Finisher callbacks by animation kind

ANIM_FINISHERS = {}

function ANIM_FINISHERS.move(a)
  turtle.col = a.target_col
  turtle.row = a.target_row
  turtle.dir = a.move_dir
  table.insert(turtle.traces, {
    c1 = a.from_col,
    r1 = a.from_row,
    c2 = a.target_col,
    r2 = a.target_row,
  })
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

-- Start a move in an absolute direction

function moveTarget(dir)
  local d = DIR_DELTA[dir]
  return turtle.col + d.x, turtle.row + d.y
end

function startBump(dir)
  local t = ANIM.move_time * ANIM.bump_frac
  startAnim("bump", t)
  turtle.anim.move_dir = dir
end

function startMove(dir)
  local tc, tr = moveTarget(dir)
  if isWall(tc, tr) then
    startBump(dir)
    return
  end
  startAnim("move", ANIM.move_time)
  turtle.anim.target_col = tc
  turtle.anim.target_row = tr
  turtle.anim.move_dir = dir
end

-- Dequeue and execute the next command

function executeNext()
  local cmd = dequeue()
  if cmd then
    startMove(cmd)
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
