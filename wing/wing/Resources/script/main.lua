--===================================================
-- File Name    : main.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-08-07 13:06:54
-- Description  :
-- Modify       :
--===================================================


-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(debug.traceback())
    print("----------------------------------------")
end

require("preload")

local sharedDirector = CCDirector:sharedDirector()
local sharedEngine = SimpleAudioEngine:sharedEngine()
local sharedFileUtils = CCFileUtils:sharedFileUtils()

local tbVisibleSize = sharedDirector:getVisibleSize()
local tbOrigin = sharedDirector:getVisibleOrigin()
local nOffsetX, nOffsetY = 0, 0

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

function cclog(...)
    print(string.format(...))
end

local function main()
	-- avoid memory leak
	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)
	
	-- play background music, preload effect
	
	-- uncomment below for the BlackBerry version
	-- local bgMusicPath = sharedFileUtils:fullPathForFilename("background.ogg")
	-- local bgMusicPath = sharedFileUtils:fullPathForFilename("1.mp3")
	-- sharedEngine:playBackgroundMusic(bgMusicPath, true)
	-- local effectPath = sharedFileUtils:fullPathForFilename("effect1.wav")
	-- sharedEngine:preloadEffect(effectPath)
	
	math.randomseed(os.time())
	math.random(100)
	Event:Preload()
    Debug:Init(Debug.MODE_BLACK_LIST)
    
	GameMgr:Init()
    SceneMgr:Init()
    MenuMgr:Init()
    Hero:Init()
    Monster:Init()
    
	Maze:Init(Def.MAZE_LOGIC_WIDTH, Def.MAZE_LOGIC_HEIGHT)
	Lib:SafeCall({Maze.Load, Maze})

	local function StartGame(nState)
        -- run
		local tbScene = SceneMgr:CreateScene("GameScene", "GameScene")
	    local sceneGame = tbScene:GetCCObj()

	    local layerGameMenu = MenuMgr:CreateMenu("GameMenu")
	    layerGameMenu:setPosition(tbVisibleSize.width, tbVisibleSize.height)
	    sceneGame:addChild(layerGameMenu, 10)

	    local layerMonsterMenu = MenuMgr:CreateMenu("PutMonster")
	    sceneGame:addChild(layerMonsterMenu, Def.ZOOM_LEVEL_SUB_MENU)
	    layerMonsterMenu:setVisible(false)
	    layerMonsterMenu:setPosition(tbVisibleSize.width / 2, tbVisibleSize.height / 2)
	    
	    local layerWorld = tbScene:Create()
		sceneGame:addChild(layerWorld, Def.ZOOM_LEVEL_WORLD)
	    GameMgr.layerWorld = layerWorld

	    Performance:Init(layerWorld)
	    GameMgr:InitTitle()
	    GameMgr:SetState(nState)
	    GameMgr:SetSpeedMulti(1)
	    Player:Init()
	    Lib:SafeCall({Player.Load, Player})
			
		sharedDirector:replaceScene(sceneGame)

		DoTest()
    end	

	local tbMainScene = SceneMgr:CreateScene("MainScene", "MainScene")
	local sceneMain = tbMainScene:GetCCObj()
	local layerBG = tbMainScene:Create()
	sceneMain:addChild(layerBG, Def.ZOOM_LEVEL_WORLD)

	local layerMainMenu = MenuMgr:CreateMenu("MainMenu")
	layerMainMenu:setPosition(tbVisibleSize.width / 2, tbVisibleSize.height / 6)
    sceneMain:addChild(layerMainMenu, Def.ZOOM_LEVEL_MENU)
    local tbElement = {
	    [1] = {
	        [1] = {
	        	szItemName = "开始游戏",
	        	fnCallBack = function()
	        		StartGame(GameMgr.STATE_NORMAL)
	        	end,
	        },
	        [2] = {
	        	szItemName = "技能测试",
	        	fnCallBack = function()
	        		StartGame(GameMgr.STATE_TEST_SKILL)
	        	end,
	        },
	        [3] = {
	        	szItemName = "编辑关卡",
	        	fnCallBack = function()
	        		StartGame(GameMgr.STATE_EDIT)
	        	end,
	        },
	    },
    }
    MenuMgr:UpdateByString("MainMenu", tbElement, {szFontName = Def.szMenuFontName, nSize = 26, szAlignType = "center", nIntervalX = 20})
    sharedDirector:runWithScene(sceneMain)
end

xpcall(main, __G__TRACKBACK__)

