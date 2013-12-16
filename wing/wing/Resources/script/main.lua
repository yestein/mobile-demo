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
	        		GameMgr:StartGame(GameMgr.STATE_NORMAL)
	        	end,
	        },
	        [2] = {
	        	szItemName = "技能测试",
	        	fnCallBack = function()
	        		GameMgr:StartGame(GameMgr.STATE_TEST_SKILL)
	        	end,
	        },
	        [3] = {
	        	szItemName = "编辑关卡",
	        	fnCallBack = function()
	        		GameMgr:StartGame(GameMgr.STATE_EDIT)
	        	end,
	        },
	    },
    }
    MenuMgr:UpdateByString("MainMenu", tbElement, 
    	{szFontName = Def.szMenuFontName, nSize = 26, szAlignType = "center", nIntervalX = 20}
    )
    sharedDirector:runWithScene(sceneMain)
end

xpcall(main, __G__TRACKBACK__)

