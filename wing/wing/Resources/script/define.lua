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

Def.szMenuFontName = "MarkerFelt-Thin"
if OS_WIN32 then
	Def.szMenuFontName = "Microsoft Yahei"
end

Def.USING_FOG = 0

Def.ZOOM_LEVEL_WORLD = 1
Def.ZOOM_LEVEL_BULLET = 2
Def.ZOOM_LEVEL_TITLE = 3
Def.ZOOM_LEVEL_PERFORMANCE = 4
Def.ZOOM_LEVEL_MENU = 5
Def.ZOOM_LEVEL_SUB_MENU = 6

Def.MAZE_LOGIC_WIDTH = 40
Def.MAZE_LOGIC_HEIGHT = 21
Def.BLOCK_WIDTH    = 36
Def.BLOCK_HEIGHT   = 48

Def.tbEntrance = {Def.MAZE_LOGIC_WIDTH / 2, Def.MAZE_LOGIC_HEIGHT}

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

Def.tbColor = {
	["black"] = ccc3(255, 255, 255),
	["red"]   = ccc3(255, 0, 0),
	["green"] = ccc3(0, 255, 0),
	["blue"]  = ccc3(0, 0, 255),
	["white"] = ccc3(0, 0, 0),
	["yellow"] = ccc3(255, 255, 0),
}

if OS_WIN32 then
	Def.szHeroFile  = "image/hero/wizard.png"
	Def.szBlockImg  = "image/block.png"
	Def.szBGImg     = "image/background.png"
	Def.szTitleFile = "image/ui/title_bg.png"
	Def.szFightImg  = "image/fight.png"
	Def.szMainBGImg = "image/main.png"
	Def.szStarImg   = "image/star.png"
	Def.szBarImg   = "image/ui/bar.png"
else	
	Def.szHeroFile  = "wizard.png"
	Def.szBlockImg  = "block.png"
	Def.szBGImg     = "background.png"
	Def.szTitleFile = "title_bg.png"
	Def.szFightImg  = "fight.png"
	Def.szMainBGImg = "main.png"
	Def.szStarImg   = "star.png"
	Def.szBarImg   = "bar.png"
end
