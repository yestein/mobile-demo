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

-- add the moving dog
local function creatDog()
    local frameWidth = 105
    local frameHeight = 95

    -- create dog animate
    local textureDog = sharedTextureCache:addImage(Def.szHeroFile)
    local rect = CCRectMake(0, 0, frameWidth, frameHeight)
    local frame0 = CCSpriteFrame:createWithTexture(textureDog, rect)
    rect = CCRectMake(frameWidth, 0, frameWidth, frameHeight)
    local frame1 = CCSpriteFrame:createWithTexture(textureDog, rect)

    local spriteDog = CCSprite:createWithSpriteFrame(frame0)
    spriteDog.isPaused = false
    spriteDog:setPosition(tbOrigin.x, tbOrigin.y + tbVisibleSize.height / 4 * 3)

    local animFrames = CCArray:create()

    animFrames:addObject(frame0)
    animFrames:addObject(frame1)

    local animation = CCAnimation:createWithSpriteFrames(animFrames, 0.5)
    local animate = CCAnimate:create(animation);
    spriteDog:runAction(CCRepeatForever:create(animate))

    -- moving dog at every frame
    local function tick()
        if spriteDog.isPaused then return end
        local x, y = spriteDog:getPosition()
        if x > tbOrigin.x + tbVisibleSize.width then
            x = tbOrigin.x
        else
            x = x + 1
        end

        spriteDog:setPositionX(x)
    end

    sharedDirector:getScheduler():scheduleScriptFunc(tick, 0, false)

    return spriteDog
end

 -- create farm
local function createLayerFarm()
    local layerFarm = CCLayer:create()

    -- add in farm background
    local bg = CCSprite:create(Def.szBGImg)
    local tbSize = bg:getTextureRect().size
    nOffsetX = tbVisibleSize.width / 2
    nOffsetY = tbVisibleSize.height / 2
    bg:setPosition(tbOrigin.x, tbOrigin.y)
    layerFarm:setPosition(nOffsetX, nOffsetY)
    layerFarm:addChild(bg)

        --[[
        -- add land sprite
        for i = 0, 3 do
            for j = 0, 1 do
                local spriteLand = CCSprite:create("land.png")
                spriteLand:setPosition(200 + j * 180 - i % 2 * 90, 10 + i * 95 / 2)
                layerFarm:addChild(spriteLand)
            end
        end

        -- add crop
        local frameCrop = CCSpriteFrame:create("crop.png", CCRectMake(0, 0, 105, 95))
        for i = 0, 3 do
            for j = 0, 1 do
                local spriteCrop = CCSprite:createWithSpriteFrame(frameCrop);
                spriteCrop:setPosition(10 + 200 + j * 180 - i % 2 * 90, 30 + 10 + i * 95 / 2)
                layerFarm:addChild(spriteCrop)
            end
        end
        --]]

        -- add moving dog
        --local spriteDog = creatDog()
        --layerFarm:addChild(spriteDog)

    local tbBlock = Maze:GenBlock(bg)
    for _, pBlock in ipairs(tbBlock) do
        layerFarm:addChild(pBlock)
    end

    -- handing touch events
    local touchBeginPoint = nil
    local touchMoveStartPoint = nil

    local function onTouchBegan(x, y)
        cclog("onTouchBegan: %0.2f, %0.2f", x, y)
        --cclog("Logic: %d, %d", nLogicX, nLogicY)
        touchBeginPoint = {x = x, y = y}
        touchMoveStartPoint = {x = x, y = y}
        
        --spriteDog.isPaused = true
        -- CCTOUCHBEGAN event must return true
        return true
    end

    local function onTouchMoved(x, y)
        --cclog("onTouchMoved: %0.2f, %0.2f", x, y)
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
            --cclog("layerFarm: %0.2f, %0.2f", nNewX, nNewY)
        end
    end

    local function onTouchEnded(x, y)
        cclog("onTouchEnded: %0.2f, %0.2f", x, y)
        if x == touchMoveStartPoint.x and y == touchMoveStartPoint.y then
	        local nX, nY = layerFarm:getPosition()
	        local nLogicX, nLogicY = x - nX, y - nY
	        nLogicX = math.floor(nLogicX / Def.BLOCK_WIDTH)
	        nLogicY = math.floor(nLogicY / Def.BLOCK_HEIGHT)

            local tbSize = bg:getTextureRect().size
	        local nCol = nLogicX + Def.MAZE_COL_COUNT / 2 + 1
	        local nRow = nLogicY + math.floor(tbSize.height / Def.BLOCK_HEIGHT / 2) + 1
	        if nRow <= Def.MAZE_ROW_COUNT then
	            Maze.tbData[nRow][nCol] = 1
	            local pBlock = Maze.tbBlock[nRow][nCol]
                if pBlock then
	               pBlock:setVisible(false)
               end
	        end
	    end
        touchBeginPoint = nil
        --spriteDog.isPaused = false
    end

    local function onTouch(eventType, x, y)
        if eventType == "began" then   
            return onTouchBegan(x, y)
        elseif eventType == "moved" then
            return onTouchMoved(x, y)
        else
            --cclog("Type:%s X:%d Y:%d", eventType, x, y)
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
    local menuReset = CCMenuItemImage:create("menu1.png", "menu1.png")
    menuReset:registerScriptTapHandler(menuCallbackReset)    
    local itemWidth = menuReset:getContentSize().width
    local itemHeight = menuReset:getContentSize().height
    menuReset:setPosition(itemWidth / 2, itemHeight / 2)
    menuArray:addObject(menuReset)
    
    local menuSave = CCMenuItemImage:create("menu1.png", "menu1.png")
    menuSave:registerScriptTapHandler(menuCallbackSave)    
    menuSave:setPosition(itemWidth / 2, itemHeight * 3 / 2)
    menuArray:addObject(menuSave)
    
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
    Maze:Init(Def.MAZE_COL_COUNT, Def.MAZE_ROW_COUNT)
    Maze:Load()

    -- run
    local sceneGame = CCScene:create()
    local layerBG = createLayerFarm()
    sceneGame:addChild(layerBG)
    
    local layerMenu = createMenu()
    sceneGame:addChild(layerMenu)
    sharedDirector:runWithScene(sceneGame)    
end

xpcall(main, __G__TRACKBACK__)
