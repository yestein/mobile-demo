--===================================================
-- File Name    : maze.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-08-07 13:06:47
-- Description  :
-- Modify       :
--===================================================


local MAP_FREE = 1
local MAP_BLOCK = 2
local MAP_MONSTER = 3

local STATE_NORMAL = 1
local STATE_EDIT = 2
local STATE_BATTLE = 3

local sharedTextureCache = CCTextureCache:sharedTextureCache()

function Maze:GetSize()
	return self.tbSize
end

function Maze:SetSize(tbSize)
	self.tbSize = {width = tbSize.width, height = tbSize.height}
end

function Maze:SetState(nState)
	self.nState = nState
end

function Maze:GetState()
	return self.nState
end

function Maze:Save()
	local nState = self:GetState()
	if nState == STATE_EDIT then
		print("Save Maze")
		--Lib:Reload()
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
		self:SetState(STATE_NORMAL)
		self:ClearRecordOP()
	elseif nState == STATE_NORMAL then
		print("Start Hero Battle")
		self:SetState(STATE_BATTLE)
		Hero:Start()
		Monster:Start()
	elseif nState == STATE_BATTLE then
		Hero:Reset()
		Monster:Reset()
		print("Start Edit Maze")
		self:SetState(STATE_EDIT)
		self:InitRecordOP()
	end
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
	print("Maze:Load")
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
	self.tbRecord = {}
	self:SetState(STATE_NORMAL)
	for i = 1, nHeight do
		self.tbData[i] = {}
		for j = 1, nWidth do
			self.tbData[i][j] = MAP_BLOCK
		end
	end
end

function Maze:Dig(nRow, nCol)
	if self:GetState() ~= STATE_EDIT then
		return 0
	end
	
	if self:CheckCanDig(nRow, nCol) ~= 1 then
		print("Can not Dig", nRow, nCol)
		return 0
	end	
	local pBlock = self.tbBlock[nRow][nCol]
	if not pBlock then
		return 0
	end
    self.tbData[nRow][nCol] = MAP_FREE
    
    pBlock:setVisible(false)
    self:PushUndoPos(nRow, nCol)
   return 1
end

function Maze:PutMonster(nRow, nCol, pSprite)
	
end

function Maze:UnDoDig()
	if self:GetState() ~= STATE_EDIT then
		return 0
	end
	
	local tbPos, _ = self:GetLastPos()
	if not tbPos then
		return 0
	end
	
	self:PopUndoPos()
	local nRow, nCol = unpack(tbPos)
	local pBlock = self.tbBlock[nRow][nCol]
	if not pBlock then
		return 0
	end
    self.tbData[nRow][nCol] = MAP_BLOCK
    
    pBlock:setVisible(true)
    print("Undo Dig")
   return 1
end

function Maze:ReDoDig()
	if self:GetState() ~= STATE_EDIT then
		return 0
	end
	
	if self:PushUndoPos() ~= 1 then
		return 0
	end
	local tbPos, _ = self:GetLastPos()
	if not tbPos then
		return 0
	end
	
	local nRow, nCol = unpack(tbPos)
	local pBlock = self.tbBlock[nRow][nCol]
	if not pBlock then
		return 0
	end
    self.tbData[nRow][nCol] = MAP_FREE
    
    pBlock:setVisible(false)
    print("Redo Dig")
   return 1
end

function Maze:InitRecordOP()
	self.tbRecordPos = {}
	self.nIndex = 0
end

function Maze:ClearRecordOP()
	self.tbRecordPos = nil
	self.nIndex = nil
end

function Maze:PushUndoPos(nRow, nCol)
	if nRow and nCol then
		self.nIndex = self.nIndex + 1
		self.tbRecordPos[self.nIndex] = {nRow, nCol}
		return 1
	else
		if self.tbRecordPos[self.nIndex + 1] then
			self.nIndex = self.nIndex + 1
			return 1
		end
	end
	return 0
end

function Maze:GetLastPos()
	return self.tbRecordPos[self.nIndex]
end

function Maze:PopUndoPos()
	self.nIndex = self.nIndex - 1
	return self.nIndex
end

function Maze:CheckCanDig(nRow, nCol)	
	local tbCheckPos = {
		{nRow - 1, nCol},
		{nRow + 1, nCol},
		{nRow, nCol - 1},
		{nRow, nCol + 1},
	}

	if nRow > Def.MAZE_ROW_COUNT then
		return 0
	end
	for _, tbPos in ipairs(tbCheckPos) do
		if self.tbData[tbPos[1]] then
			local nValue = self.tbData[tbPos[1]][tbPos[2]]
			if nValue and nValue == MAP_FREE then
				return 1
			end
		end
	end
	return 0
end
function Maze:Reset()
	print("Maze:Rest")
	for nRow , tbRow in ipairs(self.tbData) do
		for nCol, _ in ipairs(tbRow) do
			self.tbData[nRow][nCol] = MAP_BLOCK
			self.tbBlock[nRow][nCol]:setVisible(true)
		end
	end
	local nEnterRow, nEnterCol = unpack(Def.tbEntrance)
	self.tbData[nEnterRow][nEnterCol] = MAP_FREE
	self.tbBlock[nEnterRow][nEnterCol]:setVisible(false)
end

function Maze:RandomMaze()
	for nRow, tbRow in ipairs(self.tbData) do
		for nColumn, nData in ipairs(tbRow) do
			tbRow[nColumn] = math.random(1, 2)
		end
	end
end

function Maze:GenBlock()

    local textureBlock = sharedTextureCache:addImage(Def.szBlockImg)
    local rect = CCRectMake(0, 0, Def.BLOCK_WIDTH, Def.BLOCK_HEIGHT)
    local frame0 = CCSpriteFrame:createWithTexture(textureBlock, rect)
    

    local tbSprite = {}
    self.tbBlock = {}
    local tbSize = self:GetSize()
    local nStartX = -tbSize.width / 2 + Def.BLOCK_WIDTH / 2
    local nStartY = -tbSize.height / 2 + Def.BLOCK_HEIGHT / 2
    for nRow, tbRow in ipairs(self.tbData) do
    	self.tbBlock[nRow] = {}
		for nColumn, nData in ipairs(tbRow) do
			local pSprite = CCSprite:createWithSpriteFrame(frame0)
			self.tbBlock[nRow][nColumn] = pSprite
    		pSprite:setPosition(nStartX + (nColumn - 1) * Def.BLOCK_WIDTH, nStartY + (nRow - 1) * Def.BLOCK_HEIGHT)
    		tbSprite[#tbSprite + 1] = pSprite
			if nData ~= MAP_BLOCK then
				pSprite:setVisible(false)
	    	end
	    	
	    	if nData == MAP_MONSTER then
	    		local tbMonster, pMonster = Monster:NewMonster(nStartX + (nColumn - 1) * Def.BLOCK_WIDTH, nStartY + (nRow - 1) * Def.BLOCK_HEIGHT)
	    		
	    		tbSprite[#tbSprite + 1] = pMonster
	    	end
		end
	end

	return tbSprite
end

function Maze:CanMove(nX, nY)
	local nRow, nCol = Lib:GetRowColByPos(nX, nY)
	if nRow > Def.MAZE_ROW_COUNT then
		return 0
	end
	if self.tbData[nRow][nCol] == MAP_BLOCK then
		return 0
	end
	return 1

end

function Maze:IsFree(nRow, nCol)
	if nRow > Def.MAZE_ROW_COUNT then
		return 0
	end
	if self.tbData[nRow][nCol] == MAP_FREE then
		return 1
	end
	return 0
end
