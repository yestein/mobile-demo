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
	
	GameMgr:Init()
    SceneMgr:Init()
    MenuMgr:Init()
    
	Maze:Init(Def.MAZE_COL_COUNT, Def.MAZE_ROW_COUNT)
	Maze:Load()


	-- run
	local tbScene = SceneMgr:CreateScene("GameScene", "GameScene")
    local layerWorld = tbScene:Create()
    local sceneGame = tbScene:GetCCObj()
	
	sceneGame:addChild(layerWorld)
    GameMgr.layerWorld = layerWorld

    GameMgr:InitTitle()
    
	
	local layerMenu = MenuMgr:CreateMenu("MainMenu")
    sceneGame:addChild(layerMenu)
    local tbElement = {
        {
            szNormalImg = "reset_normal.png",
            szPressedImg = "reset.png", 
            fnCallBack = function()
                Maze:Reset()
            end
        },
        {
            szNormalImg = "switch_normal.png",
            szPressedImg = "switch.png", 
            fnCallBack = function()
                GameMgr:Switch()
            end
        },
        {
            szNormalImg = "undo_normal.png",
            szPressedImg = "undo.png", 
            fnCallBack = function()
                 Maze:UnDoDig()
            end
        },
        {
            szNormalImg = "redo_normal.png",
            szPressedImg = "redo.png", 
            fnCallBack = function()
                Maze:ReDoDig()
            end
        },
    }
    MenuMgr:AddElement("MainMenu", tbElement)	

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

