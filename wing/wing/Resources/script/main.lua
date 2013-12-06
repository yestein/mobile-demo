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
	-- local bgMusicPath = sharedFileUtils:fullPathForFilename("background.mp3")
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
    
	Maze:Init(Def.MAZE_COL_COUNT, Def.MAZE_ROW_COUNT)
	Lib:SafeCall({Maze.Load, Maze})

	-- run
	local tbScene = SceneMgr:CreateScene("GameScene", "GameScene")
    local sceneGame = tbScene:GetCCObj()

    local layerMainMenu = MenuMgr:CreateMenu("MainMenu")
    layerMainMenu:setPosition(tbVisibleSize.width, tbVisibleSize.height)
    sceneGame:addChild(layerMainMenu, Def.ZOOM_LEVEL_MENU)

    local layerMonsterMenu = MenuMgr:CreateMenu("PutMonster")
    sceneGame:addChild(layerMonsterMenu, Def.ZOOM_LEVEL_SUB_MENU)
    layerMonsterMenu:setVisible(false)
    layerMonsterMenu:setPosition(tbVisibleSize.width / 2, tbVisibleSize.height / 2)
    

    local layerWorld = tbScene:Create()
	sceneGame:addChild(layerWorld, Def.ZOOM_LEVEL_WORLD)
    GameMgr.layerWorld = layerWorld

    Performance:Init(layerWorld)
    GameMgr:InitTitle()
    GameMgr:SetState(GameMgr.STATE_NORMAL)
    Player:Init()
    Lib:SafeCall({Player.Load, Player})
		
	sharedDirector:runWithScene(sceneGame)
end

xpcall(main, __G__TRACKBACK__)


local function DoTest()
	local nX , nY = Lib:GetPositionByRowCol(1, 1)
	assert(nX == -702)
	assert(nY == -696)
	
	nX , nY = Lib:GetPositionByRowCol(21, 40)
	assert(nX == 702)
	assert(nY == 264)
end

DoTest()

