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

local szMenuFontName = "Microsoft Yahei"
function GameMgr:Init()
	self.tbCharacterMap = {}
	self.nState = self.STATE_NORMAL
end

function GameMgr:SetState(nState)
	local funcEnd = self.fnEndState[self.nState]
	if funcEnd then
		funcEnd(self)
	end
	self.nState = nState
	local funcStart = self.fnStartState[nState]
	if funcStart then
		funcStart(self)
	end
	Event:FireEvent("GameMgrSetState", nState)
end

function GameMgr:GetState()
	return self.nState
end

function GameMgr:GetStateDesc(nState)
	return self.tbStateDesc[nState]
end

function GameMgr:StartBattle()
	self.bPause = 0
	for dwId, tbCharacter in pairs(self.tbCharacterMap) do
		tbCharacter:Start()
	end
	Event:FireEvent("GameMgrStartBattle")
end

function GameMgr:PauseBattle()
	if self.bPause == 0 then
		for dwId, tbCharacter in pairs(self.tbCharacterMap) do
			tbCharacter:Pause()
		end
		Event:FireEvent("PauseBattle")
		self.bPause = 1
	else
		for dwId, tbCharacter in pairs(self.tbCharacterMap) do
			tbCharacter:CancelPause()
		end
		self.bPause = 0
		Event:FireEvent("CancelPauseBattle")
	end
	
end

function GameMgr:Reset()
	for dwId, tbCharacter in pairs(self.tbCharacterMap) do
		tbCharacter:Reset()
	end
	Event:FireEvent("GameMgrStartReset")
end

function GameMgr:SwitchState()
	local nState = self:GetState()
	local nNewState = nState + 1
	if nNewState > self.STATE_COUNT then
		nNewState = nNewState - self.STATE_COUNT
	end
	self:SetState(nNewState)
end


function GameMgr:OnStart_Normal()
	local tbElement = {
		{
	        [1] = {
	        	szItemName = "开始编辑",
	        	fnCallBack = function()
	                GameMgr:SwitchState()
	            end,
	        },
	    },
    }
    MenuMgr:UpdateByString("MainMenu", tbElement, szMenuFontName, 20)
    local tbScene = SceneMgr:GetScene("GameScene")
	if tbScene then
		tbScene:GenMonster()
	end
	self:StartBattle()
end
function GameMgr:OnEnd_Normal()
	Monster:ClearAll()
end

function GameMgr:OnStart_Edit()
	Maze:InitRecordOP()
	local tbElement = {
		[1] = {
			{
	            szItemName = "开始战斗",
	            fnCallBack = function()
	                GameMgr:SwitchState()
	            end
	        },
	        {
	            szItemName = "清空地图",
	            fnCallBack = function()
	                Maze:Reset()
	            end
	        },
	    },
		[2] = {
			{
				szItemName = "摆放怪物",
				fnCallBack = GameMgr.OnClickPutMonster,
			},
	        {
	            szItemName = "撤销",
	            fnCallBack = function()
	                 Maze:UnDoDig()
	            end
	        },
	        {
	            szItemName = "重做",
	            fnCallBack = function()
	                Maze:ReDoDig()
	            end
	        },
        },		
    }
    MenuMgr:UpdateByString("MainMenu", tbElement, szMenuFontName, 20)
	local tbScene = SceneMgr:GetScene("GameScene")
	if tbScene then
		tbScene:GenMonster()
	end
end

function GameMgr.OnClickPutMonster()
	local tbMenu = MenuMgr:GetMenu("PutMonster")
	if not tbMenu then
		cclog("No Menu[PutMonster]")
		return 0
	end
	local layerMenu = tbMenu.ccmenuObj
	if not layerMenu:getChildByTag(1) then
		local tbElement = {
	    	[1] = {
		        {
		            szImage = Def.szMonsterFile,
		            tbRect = {
		            	["normal"] = {36, 0, 36, 48},
		            	["selected"] = {36 * 3, 0, 36, 48},
		            },
		            fnCallBack = function()
		            	Maze:SetMouseMonster(3)
		                layerMenu:setVisible(false)
		            end
		        },
		    },
	    }
	    MenuMgr:UpdateBySprite("PutMonster", tbElement)
	end
	layerMenu:setVisible(true)
end

function GameMgr:OnEnd_Edit()
	Maze:Save()
	Player:Save()
	Maze:ClearRecordOP()
end

function GameMgr:OnStart_Battle()
	local tbElement = {
		[1] = {
	        {
	        	szItemName = "结束战斗",
	        	fnCallBack = function()
	                GameMgr:SwitchState()
	            end,
	        },
	    },
    }
    MenuMgr:UpdateByString("MainMenu", tbElement, szMenuFontName, 20)
	local tbScene = SceneMgr:GetScene("GameScene")
	if tbScene then
		tbScene:GenHero()
	end
	self:StartBattle()
end
function GameMgr:OnEnd_Battle()
	self:Reset()
	Hero:ClearAll()
	Monster:ClearAll()
end

GameMgr.fnStartState = {
	[GameMgr.STATE_NORMAL] = GameMgr.OnStart_Normal,
	[GameMgr.STATE_EDIT]   = GameMgr.OnStart_Edit,
	[GameMgr.STATE_BATTLE] = GameMgr.OnStart_Battle,
}

GameMgr.fnEndState = {
	[GameMgr.STATE_NORMAL] = GameMgr.OnEnd_Normal,
	[GameMgr.STATE_EDIT]   = GameMgr.OnEnd_Edit,
	[GameMgr.STATE_BATTLE] = GameMgr.OnEnd_Battle,
}
