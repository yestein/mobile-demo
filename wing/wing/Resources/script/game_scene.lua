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

        if GameMgr:GetState() == GameMgr.STATE_EDIT then
            local nX, nY = layerMaze:getPosition()
            local nLogicX, nLogicY = x - nX, y - nY
            local nRow, nCol = Lib:GetRowColByPos(nLogicX, nLogicY)
            local nData = Maze:GetData(nRow, nCol)
            if nData and nData >= Maze.MAP_MONSTER_START then
                Maze:StartDrag(nRow, nCol, pSprite)
            end
        end
        return true
    end

    local function onTouchMoved(x, y)
        if touchBeginPoint then
            local tbDragInfo = Maze:GetDragInfo()
            if tbDragInfo then
                local nX, nY = tbDragInfo.pSprite:getPosition()
                local nNewX, nNewY = nX + x - touchBeginPoint.x, nY + y - touchBeginPoint.y
                tbDragInfo.pSprite:setPosition(nNewX, nNewY)
            else                
                local nX, nY = layerMaze:getPosition()
                local nNewX, nNewY = nX + x - touchBeginPoint.x, nY + y - touchBeginPoint.y
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
            end
            touchBeginPoint = {x = x, y = y}
		end
    end

    local function onTouchEnded(x, y)
        if GameMgr:GetState() == GameMgr.STATE_BATTLE then
            if x == touchMoveStartPoint.x and y == touchMoveStartPoint.y then
                GameMgr:PauseBattle()
            end
        elseif GameMgr:GetState() == GameMgr.STATE_EDIT then
            local tbDragInfo = Maze:GetDragInfo()
            if tbDragInfo then
                local nMazeX, nMazeY = layerMaze:getPosition()
                local nLogicX, nLogicY = x - nMazeX, y - nMazeY
                local nRow, nCol = Lib:GetRowColByPos(nLogicX, nLogicY)
                local pSprite = tbDragInfo.pSprite
                local bRet = Maze:StopDrag(nRow, nCol)
                if bRet == 0 then
                    nRow = tbDragInfo.nRow
                    nCol = tbDragInfo.nCol
                end
                local tbSize = Maze:GetSize()
                local nStartX = -tbSize.width / 2 + Def.BLOCK_WIDTH / 2
                local nStartY = -tbSize.height / 2 + Def.BLOCK_HEIGHT / 2
                local nX, nY = nStartX + (nCol - 1) * Def.BLOCK_WIDTH, nStartY + (nRow - 1) * Def.BLOCK_HEIGHT
                pSprite:setPosition(nX, nY)
            else
                if x == touchMoveStartPoint.x and y == touchMoveStartPoint.y then
        	        local nX, nY = layerMaze:getPosition()
        	        local nLogicX, nLogicY = x - nX, y - nY
        	        nLogicX = math.floor(nLogicX / Def.BLOCK_WIDTH)
        	        nLogicY = math.floor(nLogicY / Def.BLOCK_HEIGHT)

                    local tbSize = ccspMaze:getTextureRect().size
        	        local nCol = nLogicX + Def.MAZE_COL_COUNT / 2 + 1
        	        local nRow = nLogicY + math.floor(tbSize.height / Def.BLOCK_HEIGHT / 2) + 1
                    local dwMonsterTemplateId = Maze:GetMouseMonster()
                    if dwMonsterTemplateId then
                        local bRet = Maze:PutMonster(nRow, nCol, dwMonsterTemplateId)
                        if bRet == 1 then
                            local tbSize = Maze:GetSize()
                            local nStartX = -tbSize.width / 2 + Def.BLOCK_WIDTH / 2
                            local nStartY = -tbSize.height / 2 + Def.BLOCK_HEIGHT / 2
                            local nX, nY = nStartX + (nCol - 1) * Def.BLOCK_WIDTH, nStartY + (nRow - 1) * Def.BLOCK_HEIGHT
                            local tbMonster, pMonster = Monster:NewMonster(dwMonsterTemplateId, nX, nY)
                            self.layerMaze:addChild(pMonster)
                            Maze:ClearMouseMonster()
                        end
                    else
                        local bRet = Maze:Dig(nRow, nCol)
                    end
                end
	        end
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
    Event:FireEvent("SceneCreate", self.szClassName, self.szSceneName)
    return layerMaze
end

function GameScene:RemoveSprite(pSprite)
	self.layerMaze:removeChild(pSprite, true)
end

function GameScene:GenMonster()
    local tbSize = Maze:GetSize()
    local nStartX = -tbSize.width / 2 + Def.BLOCK_WIDTH / 2
    local nStartY = -tbSize.height / 2 + Def.BLOCK_HEIGHT / 2
    for nRow, tbRow in ipairs(Maze:GetAllData()) do
        for nColumn, nData in ipairs(tbRow) do
            local nX, nY = nStartX + (nColumn - 1) * Def.BLOCK_WIDTH, nStartY + (nRow - 1) * Def.BLOCK_HEIGHT
            if nData >= Maze.MAP_MONSTER_START then
                local dwMonsterTemplateId = nData - Maze.MAP_MONSTER_START + 1
                local tbMonster, pMonster = Monster:NewMonster(dwMonsterTemplateId, nX, nY)
                self.layerMaze:addChild(pMonster)
            end
        end
    end
end

function GameScene:GenSingleMonster(dwMonsterTemplateId, nRow, nCol)
    local tbSize = Maze:GetSize()
    local nStartX = -tbSize.width / 2 + Def.BLOCK_WIDTH / 2
    local nStartY = -tbSize.height / 2 + Def.BLOCK_HEIGHT / 2
    local nX, nY = nStartX + (nCol - 1) * Def.BLOCK_WIDTH, nStartY + (nRow - 1) * Def.BLOCK_HEIGHT
    local tbMonster, pMonster = Monster:NewMonster(dwMonsterTemplateId, nX, nY)
    self.layerMaze:addChild(pMonster)
    return tbMonster, pMonster
end

function GameScene:GenHero(dwHeroTemplateId, nRow, nCol)
    local tbSize = self.spriteMaze:getTextureRect().size
    local nStartX = -tbSize.width / 2 + Def.BLOCK_WIDTH / 2
    local nStartY = -tbSize.height / 2 + Def.BLOCK_HEIGHT / 2
    nStartX = nStartX + (nCol - 1) * Def.BLOCK_WIDTH
    nStartY = nStartY + (nRow - 1) * Def.BLOCK_HEIGHT

    local tbHero, pSpriteHero = Hero:NewHero(dwHeroTemplateId, nStartX, nStartY)    
    self.layerMaze:addChild(pSpriteHero, 0, tbHero.dwId)
    return tbHero, pSpriteHero
end