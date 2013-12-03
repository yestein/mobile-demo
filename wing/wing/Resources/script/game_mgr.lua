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
	cclog("switch to %s", self.tbStateDesc[nState])
	GameMgr:UpdateTitle()
	local funcStart = self.fnStartState[nState]
	if funcStart then
		funcStart(self)
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


function GameMgr:OnStart_Normal()
	local tbElement = {
		{
	        [1] = {
	        	szItemName = "开始编辑",
	        	fnCallBack = function()
	                GameMgr:Switch()
	            end,
	        },
	    },
    }
    MenuMgr:UpdateByString("MainMenu", tbElement, szMenuFontName, 20)
end
function GameMgr:OnEnd_Normal()

end

function GameMgr:OnStart_Edit()
	Maze:InitRecordOP()
	local tbElement = {
		[1] = {
			{
	            szItemName = "开始战斗",
	            fnCallBack = function()
	                GameMgr:Switch()
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
	Maze:ClearRecordOP()
end

function GameMgr:OnStart_Battle()
	local tbElement = {
		[1] = {
	        {
	        	szItemName = "结束战斗",
	        	fnCallBack = function()
	                GameMgr:Switch()
	            end,
	        },
	    },
    }
    MenuMgr:UpdateByString("MainMenu", tbElement, szMenuFontName, 20)
	local tbScene = SceneMgr:GetScene("GameScene")
	if tbScene then
		tbScene:GenHero()
	end
	self:Start()
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
