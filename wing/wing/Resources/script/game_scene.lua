--=======================================================================
-- File Name    : game_scene.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-11-29 21:16:43
-- Description  :
-- Modify       :
--=======================================================================

local GameScene = SceneMgr:GetClass("GameScene", 1)

function GameScene:Create()
	local sceneGame = self:GetCCObj()
	if not sceneGame then
		return
	end

	local tbVisibleSize = CCDirector:sharedDirector():getVisibleSize()
	local tbOrigin = CCDirector:sharedDirector():getVisibleOrigin()
    local nOffsetX = tbVisibleSize.width / 2
    local nOffsetY = tbVisibleSize.height / 2

    local layerMaze = CCLayer:create()
    local ccspMaze = CCSprite:create(Def.szBGImg)
    local tbSize = ccspMaze:getTextureRect().size

    ccspMaze:setPosition(tbOrigin.x, tbOrigin.y)
    layerMaze:setPosition(nOffsetX, nOffsetY - 200)
    layerMaze:addChild(ccspMaze)

    Maze:SetSize(ccspMaze:getTextureRect().size)

    local tbBlock = Maze:GenBlock(ccspMaze)
    for _, pBlock in ipairs(tbBlock) do
        layerMaze:addChild(pBlock)
    end
    
    local spriteBullet = Bullet:Init()
    layerMaze:addChild(spriteBullet)

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
            local cx, cy = layerMaze:getPosition()
            local nNewX, nNewY = cx + x - touchBeginPoint.x, cy + y - touchBeginPoint.y
            local tbSize = ccspMaze:getTextureRect().size
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
            layerMaze:setPosition(nNewX, nNewY)
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
            
	        local nX, nY = layerMaze:getPosition()
	        local nLogicX, nLogicY = x - nX, y - nY
	        nLogicX = math.floor(nLogicX / Def.BLOCK_WIDTH)
	        nLogicY = math.floor(nLogicY / Def.BLOCK_HEIGHT)

            local tbSize = ccspMaze:getTextureRect().size
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

    layerMaze:registerScriptTouchHandler(onTouch)
    layerMaze:setTouchEnabled(true)

    self.layerMaze = layerMaze
    self.spriteMaze = ccspMaze
    return layerMaze
end

function GameScene:RemoveSprite(pSprite)
	self.layerMaze:removeChild(pSprite, true)
end

function GameScene:GenMonster()
    local tbSize = Maze:GetSize()
    local nStartX = -tbSize.width / 2 + Def.BLOCK_WIDTH / 2
    local nStartY = -tbSize.height / 2 + Def.BLOCK_HEIGHT / 2
    for nRow, tbRow in ipairs(Maze:GetData()) do
        for nColumn, nData in ipairs(tbRow) do
            local nX, nY = nStartX + (nColumn - 1) * Def.BLOCK_WIDTH, nStartY + (nRow - 1) * Def.BLOCK_HEIGHT
            if nData >= Maze.MAP_MONSTER_START then
                local nMonsterTemplateId = nData - Maze.MAP_MONSTER_START + 1
                local tbMonster, pMonster = Monster:NewMonster(nMonsterTemplateId, nX, nY)
                self.layerMaze:addChild(pMonster)
            end
        end
    end
end

function GameScene:GenHero()
    local tbSize = self.spriteMaze:getTextureRect().size
    local nStartX = -tbSize.width / 2 + Def.BLOCK_WIDTH / 2
    local nStartY = -tbSize.height / 2 + Def.BLOCK_HEIGHT / 2
    nStartX = nStartX + (Def.MAZE_COL_COUNT / 2 - 1) * Def.BLOCK_WIDTH
    nStartY = nStartY + (Def.MAZE_ROW_COUNT - 1) * Def.BLOCK_HEIGHT

    local tbProperty = {
        AttackRange = 3,
        Speed = 3,
    }
    local tbHero, pSpriteHero = Hero:NewHero(nStartX, nStartY, tbProperty)    
    self.layerMaze:addChild(pSpriteHero, 0, tbHero.dwId)
end