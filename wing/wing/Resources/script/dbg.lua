--=======================================================================
-- File Name    : debug.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-12-2 20:32:24
-- Description  :
-- Modify       :
--=======================================================================

Debug.MODE_BLACK_LIST = 1
Debug.MODE_WHITE_LIST = 2

Debug.tbWatchEventList = {
	"CharacterBeAttacked",
	"CharacterDie",
	"CharacterStartMove",
	"CharacterReset",
	"GameMgrStartBattle",
	"GameMgrStartReset",
	"GameMgrSwitchState",
	"SceneCreate",
	"HeroAdd",
	"LoadMaze",
	"SaveMaze",
	"Dig",
}

Debug.tbWatchEventBlackList = {
	["CharacterMove"] = 1,
	["CharacterGoto"] = 1,
	["SetUnit"] = 1,
	["TitleHPUpdate"] = 1,
	["TitleStateUpdate"] = 1,
	["GameMgrSwitchState"] = 1,
}

function Debug:Init(nMode)
	if nMode == self.MODE_BLACK_LIST then
		Event:RegistWatcher(Debug.tbWatchEventBlackList, self.Print)
	elseif nMode == self.MODE_WHITE_LIST then
		for _, szEvent in ipairs(Debug.tbWatchEventList) do
			Event:RegistEvent(szEvent, self.Print, szEvent)
		end
	end
end

function Debug.Print(...)
	print(...)
end
