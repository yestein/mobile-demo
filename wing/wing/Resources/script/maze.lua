--===================================================
-- File Name    : maze.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-08-07 13:06:47
-- Description  :
-- Modify       :
--===================================================

local MAP_FREE = 1
local MAP_BLOCK = 2

local sharedTextureCache = CCTextureCache:sharedTextureCache()

function Maze:Save()
    local szPath = CCFileUtils:sharedFileUtils():getWritablePath()
	local file = assert(io.open(szPath.."savemap.lua", "w"))
	file:write("Maze:Entry{\n")
	for nRow, tbRow in ipairs(self.tbData) do
		file:write("{")
		for nColumn, nData in ipairs(tbRow) do
			file:write(string.format("%d, ", nData))
		end
		file:write("},\n")
	end
	file:write("}")
	file:close()
end

function Maze:Entry(tbData)
	for nRow, tbRow in ipairs(tbData) do
		for nCol, nData in ipairs(tbRow) do
			self.tbData[nRow][nCol] = nData
		end
	end
	return 1
end

function Maze:GetData()
	return self.tbData
end

function Maze:Load()
	local szPath = CCFileUtils:sharedFileUtils():getWritablePath()
	local file = io.open(szPath.."savemap.lua", "r")
	if not file then
		return
	end
	--print(file:read("*all"))
	local t = dofile(szPath.."savemap.lua")
end

function Maze:Init(nWidth, nHeight)
	self.tbData = {}
	for i = 1, nHeight do
		self.tbData[i] = {}
		for j = 1, nWidth do
			self.tbData[i][j] = MAP_BLOCK
		end
	end
end

function Maze:RandomMaze()
	for nRow, tbRow in ipairs(self.tbData) do
		for nColumn, nData in ipairs(tbRow) do
			tbRow[nColumn] = math.random(1, 2)
		end
	end
end

function Maze:GenBlock(pBg)
	local frameWidth = 20
    local frameHeight = 20

    local function onTouchBegan(x, y)

    end

    local function onTouch(eventType, x, y)
        if eventType == "began" then   
            return onTouchBegan(x, y)
        end
    end



    local textureDog = sharedTextureCache:addImage(Def.szBlockImg)
    local rect = CCRectMake(0, 0, frameWidth, frameHeight)
    local frame0 = CCSpriteFrame:createWithTexture(textureDog, rect)

    local tbSprite = {}
    self.tbBlock = {}
    local tbSize = pBg:getTextureRect().size
    local nX, nY = pBg:getPosition()
    local nStartX = -tbSize.width / 2 + frameWidth / 2
    local nStartY = -tbSize.height / 2 + frameHeight / 2
    for nRow, tbRow in ipairs(self.tbData) do
    	self.tbBlock[nRow] = {}
		for nColumn, nData in ipairs(tbRow) do
			local pSprite = CCSprite:createWithSpriteFrame(frame0)
			self.tbBlock[nRow][nColumn] = pSprite
    		pSprite:setPosition(nStartX + (nColumn - 1) * frameWidth, nStartY + (nRow - 1) * frameHeight)
    		--pSprite:registerScriptTouchHandler(onTouch)
    		--pSprite:setTouchEnabled(true)
    		tbSprite[#tbSprite + 1] = pSprite
			if nData == MAP_FREE then
				pSprite:setVisible(false)
	    	end
		end
	end

	return tbSprite
end

