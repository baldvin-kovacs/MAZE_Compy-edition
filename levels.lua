-- levels.lua
-- Direct control maze levels, graded from simple to complex.

LEVELS = {
  -- Level 1: straight corridor, 3 moves north
  {
    "####",
    "#* #",
    "#  #",
    "#  #",
    "#N #",
    "####",
  },

  -- Level 2: one turn (north then east)
  {
    "#####",
    "#  *#",
    "#   #",
    "#N  #",
    "#####",
  },

  -- Level 3: two turns
  {
    "######",
    "#*   #",
    "#### #",
    "#    #",
    "# ####",
    "#N   #",
    "######",
  },

  -- Level 4: multiple turns, longer path
  {
    "######",
    "#   *#",
    "# ## #",
    "#    #",
    "#### #",
    "#N   #",
    "######",
  },

  -- Level 5: dead end, requires backtracking
  {
    "########",
    "#   #  #",
    "# #    #",
    "# # ## #",
    "#N#  #*#",
    "########",
  },
}
