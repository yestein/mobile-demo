--===================================================
-- File Name    : define.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-08-07 13:06:59
-- Description  :
-- Modify       :
--===================================================

local Def = _G.Def

local Id = 1
local function Accumulate(nId)
	if nId then
		Id = nId
	else
		Id = Id + 1
	end
	return Id
end

Def.MAZE_ROW_COUNT = 21
Def.MAZE_COL_COUNT = 40
Def.BLOCK_WIDTH    = 36
Def.BLOCK_HEIGHT   = 48

Def.tbEntrance = {Def.MAZE_ROW_COUNT, Def.MAZE_COL_COUNT / 2}


Def.szHeroFile    = "wizard.png"
Def.szMonsterFile = "icon.pnf"
Def.szBlockImg    = "block.png"
Def.szBGImg       = "background.png"
Def.szMonsterFile = "monster.png"
Def.szBulletFile  = "bullet.png"
Def.szTitleFile = "title_bg.png"

Def.DIR_START = Accumulate(0)
Def.DIR_DOWN  = Accumulate()
Def.DIR_RIGHT = Accumulate()
Def.DIR_UP    = Accumulate()
Def.DIR_LEFT  = Accumulate()
Def.DIR_END   = Accumulate()


Def.tbMove = {
	[Def.DIR_UP]    = {0, 1},
	[Def.DIR_DOWN]  = {0, -1},
	[Def.DIR_LEFT]  = {-1, 0},
	[Def.DIR_RIGHT] = {1, 0},
}

Def.tbTextureRow = {
	[Def.DIR_DOWN]  = 0,
	[Def.DIR_LEFT]  = 1,
	[Def.DIR_UP]    = 2,
	[Def.DIR_RIGHT] = 3,
}

Def.DIR_NAME = {
	[Def.DIR_UP]    = "UP",
	[Def.DIR_DOWN]  = "DOWN",
	[Def.DIR_LEFT]  = "LEFT",
	[Def.DIR_RIGHT] = "RIGHT",
}