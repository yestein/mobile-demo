--=======================================================================
-- File Name    : game_mgr.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-09-26 13:40:31
-- Description  :
-- Modify       :
--=======================================================================

GameMgr.STATE_NORMAL = 1
GameMgr.STATE_EDIT   = 2
GameMgr.STATE_BATTLE = 3

GameMgr.STATE_COUNT = 3

GameMgr.tbStateDesc = {
	[GameMgr.STATE_NORMAL] = "普通",
	[GameMgr.STATE_EDIT]   = "编辑中",
	[GameMgr.STATE_BATTLE] = "战斗中",
}

function GameMgr:Init()
	self.tbCharacterMap = {}
	self.nState = self.STATE_NORMAL
end

function GameMgr:SetState(nState)
	self.nState = nState
	cclog("switch to %s", self.tbStateDesc[nState])
	GameMgr:UpdateTitle()
	local func = self.fnState[nState]
	if func then
		func(self)
	end
end

function GameMgr:GetState()
	return self.nState
end

function GameMgr:GetStateDesc()
	return self.tbStateDesc[self.nState]
end

function GameMgr:Start()
	for dwId, tbCharacter in pairs(self.tbCharacterMap) do
		tbCharacter:Start()
	end
end

function GameMgr:Reset()
	for dwId, tbCharacter in pairs(self.tbCharacterMap) do
		tbCharacter:Reset()
	end
end

function GameMgr:Switch()
	local nState = self:GetState()
	local nNewState = nState + 1
	if nNewState > self.STATE_COUNT then
		nNewState = nNewState - self.STATE_COUNT
	end
	self:SetState(nNewState)
end


function GameMgr:OnSwitch_Normal()
	Maze:Save()
end

function GameMgr:OnSwitch_Edit()
	self:Reset()
	Maze:InitRecordOP()
end

function GameMgr:OnSwitch_Battle()
	self:Start()
end

GameMgr.fnState = {
	[GameMgr.STATE_NORMAL] = GameMgr.OnSwitch_Normal,
	[GameMgr.STATE_EDIT]   = GameMgr.OnSwitch_Edit,
	[GameMgr.STATE_BATTLE] = GameMgr.OnSwitch_Battle,
}
