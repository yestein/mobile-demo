--=======================================================================
-- File Name    : ai.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-12-06 23:11:12
-- Description  :
-- Modify       :
--=======================================================================

require("define")
if not AI then
	AI = {}
end
local tbDefaultDirection = {Def.DIR_DOWN, Def.DIR_RIGHT, Def.DIR_UP, Def.DIR_LEFT}

AI.tbCfg = {
	["NormalMove"] = {
		tbDirection = tbDefaultDirection,
	},
	["NotMove"] = {
		tbDirection = {},
	},
}

function AI:GetDirctionList(szAIName)
	local tbRet = nil
	if self.tbCfg[szAIName] then
		tbRet = self.tbCfg[szAIName].tbDirection
	end
	if not tbRet then
		tbRet = tbDefaultDirection
	end
	return tbRet
end