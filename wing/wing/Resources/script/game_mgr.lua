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
GameMgr.STATE_TEST_SKILL = 4

GameMgr.STATE_COUNT = 3

GameMgr.tbStateDesc = {
	[GameMgr.STATE_NORMAL] = "普通",
	[GameMgr.STATE_EDIT]   = "编辑中",
	[GameMgr.STATE_BATTLE] = "战斗中",
	[GameMgr.STATE_TEST_SKILL] = "技能测试"
}
local szMenuFontName = "MarkerFelt-Thin"
if OS_WIN32 then
	szMenuFontName = "Microsoft Yahei"
end
function GameMgr:Init()
	self.tbCharacterMap = {}
	self.nState = self.STATE_NORMAL
	self.nSpeedMulti = 1
end

function GameMgr:SetSpeedMulti(nMulti)
	self.nSpeedMulti = nMulti
	Event:FireEvent("SpeedChanged", nMulti)
end

function GameMgr:GetSpeedMulti(nMulti)
	return self.nSpeedMulti
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

function GameMgr:StartGame(nState)
	local function DoTest()
		local nLogicX, nLogicY = 1, 1
		local nX , nY = Lib:GetPositionByLogicPos(nLogicX, nLogicY)
		print("logic", nLogicX, nLogicY, "->", nX, nY)
		assert(nX == -702)
		assert(nY == -696)
		
		nLogicX, nLogicY = 40, 21
		nX , nY = Lib:GetPositionByLogicPos(nLogicX, nLogicY)
		print("logic", nLogicX, nLogicY, "->", nX, nY)
		assert(nX == 702)
		assert(nY == 264)
	end
    -- run
    local sharedDirector = CCDirector:sharedDirector()
    local tbVisibleSize = sharedDirector:getVisibleSize()
	local tbScene = SceneMgr:CreateScene("GameScene", "GameScene")
    local sceneGame = tbScene:GetCCObj()

    local layerGameMenu = MenuMgr:CreateMenu("GameMenu")
    layerGameMenu:setPosition(tbVisibleSize.width, tbVisibleSize.height)
    sceneGame:addChild(layerGameMenu, Def.ZOOM_LEVEL_MENU)

    local layerSpeedMenu = MenuMgr:CreateMenu("SpeedMenu")
    layerSpeedMenu:setPosition(0, tbVisibleSize.height)
    sceneGame:addChild(layerSpeedMenu, Def.ZOOM_LEVEL_MENU)

    local tbSpeedElement = {
    	[1] = {
	        {
	        	szItemName = "1X",
	        	fnCallBack = function()
	        		GameMgr:SetSpeedMulti(1)
	            end,
	        },
	    },
	    [2] = {
	    	{
	        	szItemName = "2X",
	        	fnCallBack = function()
	                GameMgr:SetSpeedMulti(2)
	            end,
	        },
	    },
	    [3] = {
	        {
	        	szItemName = "4X",
	        	fnCallBack = function()
	                GameMgr:SetSpeedMulti(4)
	            end,
	        },
	    },
	}
	MenuMgr:UpdateByString("SpeedMenu", tbSpeedElement,  
    	{szFontName = Def.szMenuFontName, nSize = 16, szAlignType = "left"}
    )

    local layerMonsterMenu = MenuMgr:CreateMenu("PutMonster")
    sceneGame:addChild(layerMonsterMenu, Def.ZOOM_LEVEL_SUB_MENU)
    layerMonsterMenu:setVisible(false)
    layerMonsterMenu:setPosition(tbVisibleSize.width / 2, tbVisibleSize.height / 2)
    
    local layerWorld = tbScene:Create()
	sceneGame:addChild(layerWorld, Def.ZOOM_LEVEL_WORLD)
    self.layerWorld = layerWorld

    Performance:Init(layerWorld)
    GameMgr:InitTitle()
    GameMgr:SetState(nState)
    GameMgr:SetSpeedMulti(1)
    Player:Init()
    Lib:SafeCall({Player.Load, Player})

	sharedDirector:replaceScene(sceneGame)

	DoTest()
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
		[1] = {
	        [1] = {
	        	szItemName = "开始编辑",
	        	fnCallBack = function()
	                GameMgr:SetState(self.STATE_EDIT)
	            end,
	        },
	        [2] = {
	        	szItemName = "模拟战斗",
	        	fnCallBack = function()
	                GameMgr:SetState(self.STATE_BATTLE)
	            end,
	        },
	    },
	    [2] = {
	        [1] = {
	        	szItemName = "技能测试",
	        	fnCallBack = function()
	                GameMgr:SetState(self.STATE_TEST_SKILL)
	            end,
	        },
	    },
    }
    MenuMgr:UpdateByString("GameMenu", tbElement, {szFontName = szMenuFontName, nSize = 20, szAlignType = "right"})
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
	            szItemName = "结束编辑",
	            fnCallBack = function()
	                GameMgr:SetState(self.STATE_NORMAL)
	            end
	        },
	        {
	            szItemName = "清空地图",
	            fnCallBack = function()
	           		Monster:ClearAll()
	                Maze:Reset()
	                local tbScene = SceneMgr:GetScene("GameScene")
	                if tbScene then
	                	tbScene:GenMonster()
	                end
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
    MenuMgr:UpdateByString("GameMenu", tbElement, {szFontName = szMenuFontName, nSize = 20, szAlignType = "right"})
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
		local tbRect = {
        	["normal"] = {36, 0, 36, 48},
        	["selected"] = {36 * 3, 0, 36, 48},
        }
		local tbElement = {[1] = {}, }
		local tbMonster = Player:GetOwnMonster()
		local tbMenu = {}
		for dwMonsterTemplateId, nCount in pairs(tbMonster) do
			if nCount > 0 then
				local tb = {
					szImage = Monster.tbCfg[dwMonsterTemplateId].szImgFile,
					tbRect = tbRect,
					fnCallBack = function()
						Maze:SetMouseMonster(dwMonsterTemplateId)
				        layerMenu:removeChildByTag(1, true)
					end,
		        }
		        table.insert(tbElement[1], tb)
			end
		end
	    MenuMgr:UpdateBySprite("PutMonster", tbElement)
	end
	layerMenu:setVisible(true)
end

function GameMgr:OnEnd_Edit()
	Maze:Save()
	Player:Save()
	Maze:ClearRecordOP()
	Monster:ClearAll()
end

function GameMgr:OnStart_Battle()
	local tbElement = {
		[1] = {
	        {
	        	szItemName = "结束战斗",
	        	fnCallBack = function()
	        		if self.nRegGenHeroId then
	        			return
	        		end
	                GameMgr:SetState(self.STATE_NORMAL)
	            end,
	        },
	    },	    
    }
    MenuMgr:UpdateByString("GameMenu", tbElement, {szFontName = szMenuFontName, nSize = 20, szAlignType = "right"})

	local tbScene = SceneMgr:GetScene("GameScene")
	if tbScene then
		self.nMaxHero = 1
		self.nCurHero = 1
		tbScene:GenHero(self.nCurHero, unpack(Def.tbEntrance))
		tbScene:GenMonster()
		self.nRegGenHeroId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(
			function()
				self.nCurHero = self.nCurHero + 1
				if self.nCurHero > self.nMaxHero then
					CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(GameMgr.nRegGenHeroId)
					GameMgr.nRegGenHeroId = nil
					return
				end		
				local tbHero = tbScene:GenHero(self.nCurHero, unpack(Def.tbEntrance))
				tbHero:Start()
			end,
			1, false
		)
		if Def.USING_FOG == 1 then
			local tbMonsterList = Monster:GetList()
			for _, tbMonster in pairs(tbMonsterList) do
				tbMonster.pSprite:setVisible(false)
			end
			Maze:HideAllBlock()
		end
		self:StartBattle()
	end	
end
function GameMgr:OnEnd_Battle()
	self:Reset()
	Hero:ClearAll()
	Monster:ClearAll()
	Maze:Refresh()
end

function GameMgr:OnStart_TestSkill()
	local tbElement = {
		[1] = {
	        {
	        	szItemName = "结束测试",
	        	fnCallBack = function()
	                GameMgr:SetState(self.STATE_NORMAL)
	            end,
	        },
	    },
		[2] = {
			{
	        	szItemName = "英雄攻击",
	        	fnCallBack = function()
	                for dwId, tbCharacter in pairs(Hero:GetList()) do
	                	local tbMonster, nDirection = tbCharacter:TryFindMonster()
	                	if tbMonster then
							tbCharacter:GoAndAttack(nDirection, tbMonster)
						else
							tbCharacter:Attack()
						end
					end
	            end,
	        },	        
		},		
		[3] = {
			{
	        	szItemName = "怪物攻击",
	        	fnCallBack = function()
	                for dwId, tbCharacter in pairs(Monster:GetList()) do
	                	local tbHero, nDirection = tbCharacter:TryFindHero()
	                	if tbHero then
							tbCharacter:GoAndAttack(nDirection, tbHero)
						else
							tbCharacter:Attack()
						end
					end
	            end,
	        },
	        {
	        	szItemName = "一起攻击",
	        	fnCallBack = function()
	        		for dwId, tbCharacter in pairs(Hero:GetList()) do
	                	local tbMonster, nDirection = tbCharacter:TryFindMonster()
	                	if tbMonster then
							tbCharacter:GoAndAttack(nDirection, tbMonster)
						else
							tbCharacter:Attack()
						end
					end
	                for dwId, tbCharacter in pairs(Monster:GetList()) do
	                	local tbHero, nDirection = tbCharacter:TryFindHero()
	                	if tbHero then
							tbCharacter:GoAndAttack(nDirection, tbHero)
						else
							tbCharacter:Attack()
						end
					end
	            end,
	        },
		},
    }
    MenuMgr:UpdateByString("GameMenu", tbElement, {szFontName = szMenuFontName, nSize = 14, szAlignType = "right"})
	Maze:SetSkillTest()
	local tbScene = SceneMgr:GetScene("GameScene")
	if tbScene then

		local tbMagicHero = tbScene:GenHero(999, 22, 18)
		tbMagicHero:SetDirection(Def.DIR_RIGHT)
		local tbMonster1 = tbScene:GenSingleMonster(999, 24, 18)
		tbMonster1:SetDirection(Def.DIR_LEFT)
		local tbMonster2 = tbScene:GenSingleMonster(999, 25, 18)
		tbMonster2:SetDirection(Def.DIR_LEFT)
		local tbMonster3 = tbScene:GenSingleMonster(999, 22, 16)
		tbMonster3:SetDirection(Def.DIR_UP)
		local tbMonster4 = tbScene:GenSingleMonster(999, 22, 20)
		tbMonster4:SetDirection(Def.DIR_DOWN)
		local tbMonster5 = tbScene:GenSingleMonster(999, 20, 18)
		tbMonster5:SetDirection(Def.DIR_RIGHT)

		local tbPhysicHero = tbScene:GenHero(1000, 17, 19, 17)
		tbPhysicHero:SetDirection(Def.DIR_RIGHT)
		local tbMonster6 = tbScene:GenSingleMonster(1000, 17, 18)
		tbMonster6:SetDirection(Def.DIR_UP)
		local tbMonster7 = tbScene:GenSingleMonster(1000, 16, 19)
		tbMonster7:SetDirection(Def.DIR_RIGHT)
		local tbMonster8 = tbScene:GenSingleMonster(1000, 18, 19)
		tbMonster8:SetDirection(Def.DIR_LEFT)
		local tbMonster9 = tbScene:GenSingleMonster(1000, 17, 20)
		tbMonster9:SetDirection(Def.DIR_DOWN)
		
	end
end

function GameMgr:OnEnd_TestSkill()
	Maze:Load()
	Maze:Refresh()
	Hero:ClearAll()
	Monster:ClearAll()
end

GameMgr.fnStartState = {
	[GameMgr.STATE_NORMAL] = GameMgr.OnStart_Normal,
	[GameMgr.STATE_EDIT]   = GameMgr.OnStart_Edit,
	[GameMgr.STATE_BATTLE] = GameMgr.OnStart_Battle,
	[GameMgr.STATE_TEST_SKILL] = GameMgr.OnStart_TestSkill,
}

GameMgr.fnEndState = {
	[GameMgr.STATE_NORMAL] = GameMgr.OnEnd_Normal,
	[GameMgr.STATE_EDIT]   = GameMgr.OnEnd_Edit,
	[GameMgr.STATE_BATTLE] = GameMgr.OnEnd_Battle,
	[GameMgr.STATE_TEST_SKILL] = GameMgr.OnEnd_TestSkill,
}
