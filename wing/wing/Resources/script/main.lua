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
local sharedTextureCache = CCTextureCache:sharedTextureCache()
local sharedEngine = SimpleAudioEngine:sharedEngine()
local sharedFileUtils = CCFileUtils:sharedFileUtils()

local tbVisibleSize = sharedDirector:getVisibleSize()
local tbOrigin = sharedDirector:getVisibleOrigin()
local nOffsetX, nOffsetY = 0, 0

function cclog(...)
    print(string.format(...))
end

-- create farm
local function createLayerMaze()
    local layerFarm = CCLayer:create()

    -- add in farm background
    local bg = CCSprite:create(Def.szBGImg)
    local tbSize = bg:getTextureRect().size
    nOffsetX = tbVisibleSize.width / 2
    nOffsetY = tbVisibleSize.height / 2
    bg:setPosition(tbOrigin.x, tbOrigin.y)
    layerFarm:setPosition(nOffsetX, nOffsetY - 200)
    Maze:SetSize(bg:getTextureRect().size)
    layerFarm:addChild(bg)

    local nStartX = -tbSize.width / 2 + Def.BLOCK_WIDTH / 2
    local nStartY = -tbSize.height / 2 + Def.BLOCK_HEIGHT / 2
    nStartX = nStartX + (Def.MAZE_COL_COUNT / 2 - 1) * Def.BLOCK_WIDTH
    nStartY = nStartY + (Def.MAZE_ROW_COUNT - 1) * Def.BLOCK_HEIGHT
    local tbProperty = {
    	AttackRange = 6,
    	Speed = 3,
    }
    local tbHero, pSpriteHero = Hero:NewHero(nStartX, nStartY, tbProperty)    
    layerFarm:addChild(pSpriteHero)

    local tbBlock = Maze:GenBlock(bg)
    for _, pBlock in ipairs(tbBlock) do
        layerFarm:addChild(pBlock)
    end
    
    local spriteBullet = Bullet:Init()
    layerFarm:addChild(spriteBullet)

    -- handing touch events
    local touchBeginPoint = nil
    local touchMoveStartPoint = nil

    local function onTouchBegan(x, y)
        touchBeginPoint = {x = x, y = y}
        touchMoveStartPoint = {x = x, y = y}

        -- CCTOUCHBEGAN event must return true
        return true
    end

    local function onTouchMoved(x, y)

        if touchBeginPoint then
            local cx, cy = layerFarm:getPosition()
            local nNewX, nNewY = cx + x - touchBeginPoint.x, cy + y - touchBeginPoint.y
            local tbSize = bg:getTextureRect().size
            local nMinX, nMaxX = tbVisibleSize.width - tbSize.width / 2, tbSize.width / 2
            local nMinY, nMaxY = tbVisibleSize.height - tbSize.height / 2,  tbSize.height / 2
            if nNewX < nMinX then
                nNewX = nMinX
            elseif nNewX > nMaxX then
                nNewX = nMaxX
            end

            if nNewY < nMinY then
                nNewY = nMinY
            elseif nNewY > nMaxY then
                nNewY = nMaxY
            end
            layerFarm:setPosition(nNewX, nNewY)
            touchBeginPoint = {x = x, y = y}
		end
    end

    local function onTouchEnded(x, y)
        if x == touchMoveStartPoint.x and y == touchMoveStartPoint.y then

            if Maze:GetState() == Maze.STATE_BATTLE then
                if spriteHero.isPaused == true then
                    spriteHero.isPaused = false
                else
                    spriteHero.isPaused = true
                end
            end
            
	        local nX, nY = layerFarm:getPosition()
	        local nLogicX, nLogicY = x - nX, y - nY
	        nLogicX = math.floor(nLogicX / Def.BLOCK_WIDTH)
	        nLogicY = math.floor(nLogicY / Def.BLOCK_HEIGHT)

            local tbSize = bg:getTextureRect().size
	        local nCol = nLogicX + Def.MAZE_COL_COUNT / 2 + 1
	        local nRow = nLogicY + math.floor(tbSize.height / Def.BLOCK_HEIGHT / 2) + 1
	        local bRet = Maze:Dig(nRow, nCol)
	        
	    end
        touchBeginPoint = nil
    end

    local function onTouch(eventType, x, y)
        if eventType == "began" then   
            return onTouchBegan(x, y)
        elseif eventType == "moved" then
            return onTouchMoved(x, y)
        else
            return onTouchEnded(x, y)
        end
    end

    layerFarm:registerScriptTouchHandler(onTouch)
    layerFarm:setTouchEnabled(true)

    return layerFarm
end

-- create menu
local function createMenu()
    local layerMenu = CCLayer:create()

    local menuPopup, menuTools, effectID

    local function menuCallbackSave()
        -- stop test sound effect
        --SimpleAudioEngine:sharedEngine():stopEffect(effectID)
        --menuPopup:setVisible(false)
        Maze:Save()
    end

    local function menuCallbackReset()
        -- loop test sound effect
        --local effectPath = CCFileUtils:sharedFileUtils():fullPathForFilename("effect1.wav")
        --effectID = SimpleAudioEngine:sharedEngine():playEffect(effectPath)
        --menuPopup:setVisible(true)
        Maze:Reset()
        
    end
    
     local function menuCallbackUndo()
        Maze:UnDoDig()        
    end
    
     local function menuCallbackRedo()
        Maze:ReDoDig()        
    end
	
	--[[
    -- add a popup menu
    local menuPopupItem = CCMenuItemImage:create("menu2.png", "menu2.png")
    menuPopupItem:setPosition(0, 0)
    menuPopupItem:registerScriptTapHandler(menuCallbackClosePopup)
    menuPopup = CCMenu:createWithItem(menuPopupItem)
    menuPopup:setPosition(tbOrigin.x + tbVisibleSize.width / 2, tbOrigin.y + tbVisibleSize.height / 2)
    menuPopup:setVisible(false)
    layerMenu:addChild(menuPopup)
    --]]

	local menuArray = CCArray:create()
	
    -- add the left-bottom "tools" menu to invoke menuPopup
    local menuReset = CCMenuItemImage:create("reset.png", "reset.png")
    menuReset:registerScriptTapHandler(menuCallbackReset)    
    local itemWidth = menuReset:getContentSize().width
    local itemHeight = menuReset:getContentSize().height
    menuReset:setPosition(tbVisibleSize.width - itemWidth / 2, itemHeight / 2)
    menuArray:addObject(menuReset)
    
    local menuSave = CCMenuItemImage:create("switch.png", "switch.png")
    menuSave:registerScriptTapHandler(menuCallbackSave)    
    menuSave:setPosition(tbVisibleSize.width - itemWidth / 2, itemHeight * 3 / 2)
    menuArray:addObject(menuSave)
    
    local menuUndo = CCMenuItemImage:create("undo.png", "undo.png")
    menuUndo:registerScriptTapHandler(menuCallbackUndo)    
    menuUndo:setPosition(tbVisibleSize.width - itemWidth / 2, itemHeight * 5 / 2)
    menuArray:addObject(menuUndo)
    
    local menuRedo = CCMenuItemImage:create("redo.png", "redo.png")
    menuRedo:registerScriptTapHandler(menuCallbackRedo)    
    menuRedo:setPosition(tbVisibleSize.width - itemWidth / 2, itemHeight * 7 / 2)
    menuArray:addObject(menuRedo)
    
    menuTools = CCMenu:createWithArray(menuArray)
    menuTools:setPosition(tbOrigin.x, tbOrigin.y)
    layerMenu:addChild(menuTools)    

    return layerMenu
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
    local effectPath = sharedFileUtils:fullPathForFilename("effect1.wav")
    sharedEngine:preloadEffect(effectPath)

    math.randomseed(os.time())
    math.random(100)
    
    Hero:Init()
    Monster:Init()
    Maze:Init(Def.MAZE_COL_COUNT, Def.MAZE_ROW_COUNT)
    Maze:Load()

    -- run
    local sceneGame = CCScene:create()
    local layerBG = createLayerMaze()
    sceneGame:addChild(layerBG)
    
    local layerMenu = createMenu()
    sceneGame:addChild(layerMenu)
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

