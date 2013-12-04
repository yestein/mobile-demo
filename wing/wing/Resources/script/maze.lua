--===================================================
-- File Name    : maze.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-08-07 13:06:47
-- Description  :
-- Modify       :
--===================================================


local MAP_FREE     = 1
local MAP_BLOCK    = 2
Maze.MAP_MONSTER_START  = 3

local sharedTextureCache = CCTextureCache:sharedTextureCache()

function Maze:Init(nWidth, nHeight)
	self.tbData = {}
	self.tbUnit = {}
	self.tbRecord = {}
	for i = 1, nHeight do
		self.tbData[i] = {}
		self.tbUnit[i] = {}
		for j = 1, nWidth do
			self.tbData[i][j] = MAP_BLOCK
			self.tbUnit[i][j] = 0
		end
	end
end

function Maze:Entry(tbData)
	for nRow, tbRow in ipairs(tbData) do
		for nCol, nData in ipairs(tbRow) do
			if nRow == Def.MAZE_ROW_COUNT and nCol == Def.MAZE_COL_COUNT / 2 then
				self.tbData[nRow][nCol] = MAP_FREE
			else
				self.tbData[nRow][nCol] = nData
			end
		end
	end
	return 1
end

function Maze:GetData()
	return self.tbData
end

function Maze:Load()
	cclog("Load Maze ...")
	local szPath = CCFileUtils:sharedFileUtils():getWritablePath()
	local file = io.open(szPath.."savemap.lua", "r")
	if not file then
		return
	end
	local t = dofile(szPath.."savemap.lua")
	Event:FireEvent("LoadMaze")
end

function Maze:GetSize()
	return self.tbSize
end

function Maze:SetSize(tbSize)
	self.tbSize = {width = tbSize.width, height = tbSize.height}
end

function Maze:Save()
	cclog("Save Maze ...")
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
	Event:FireEvent("SaveMaze")
end

function Maze:Dig(nRow, nCol)
	if self:CheckCanDig(nRow, nCol) ~= 1 then
		cclog("Can not Dig Row[%d] Col[%d]", nRow, nCol)
		return 0
	end	
	local pBlock = self.tbBlock[nRow][nCol]
	if not pBlock then
		return 0
	end
    self.tbData[nRow][nCol] = MAP_FREE
    pBlock:setVisible(false)
    self:PushUndoPos(nRow, nCol)
    Event:FireEvent("Dig", nRow, nCol)
    return 1
end

function Maze:UnDoDig()
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
    Event:FireEvent("UnDoDig", nRow, nCol)
    return 1
end

function Maze:ReDoDig()
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
    local bReDo = 1
    Event:FireEvent("Dig", nRow, nCol, bReDo)
    return 1
end

function Maze:PutMonster(nRow, nCol, dwMonsterTemplate)
	if self.tbData[nRow][nCol] ~= MAP_FREE then
		return 0
	end
	self.tbData[nRow][nCol] = dwMonsterTemplate
	Event:FireEvent("PutMonster", nRow, nCol, dwMonsterTemplate)
	return 1
end

function Maze:MoveMonster(nRow, nCol, nNewRow, nNewCol)
	if self.tbData[nRow][nCol] < self.MAP_MONSTER_START then
		return 0
	end
	self.tbData[nNewRow][nNewCol] = self.tbData[nRow][nCol]
	self.tbData[nRow][nCol] = MAP_FREE
	Event:FireEvent("PutMonster", self.tbData[nNewRow][nNewCol], nRow, nCol, nNewRow, nNewCol)
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
	cclog("Maze:Rest")
	for nRow , tbRow in ipairs(self.tbData) do
		for nCol, _ in ipairs(tbRow) do
			self.tbData[nRow][nCol] = MAP_BLOCK
			self.tbBlock[nRow][nCol]:setVisible(true)
		end
	end
	local nEnterRow, nEnterCol = unpack(Def.tbEntrance)
	self.tbData[nEnterRow][nEnterCol] = MAP_FREE
	self.tbBlock[nEnterRow][nEnterCol]:setVisible(false)
	Event:FireEvent("ResetMaze")
end

function Maze:RandomMaze()
	for nRow, tbRow in ipairs(self.tbData) do
		for nColumn, nData in ipairs(tbRow) do
			tbRow[nColumn] = math.random(1, 2)
		end
	end
end

function Maze:CanMove(nX, nY)
	local nRow, nCol = Lib:GetRowColByPos(nX, nY)
	if self:IsFree(nRow, nCol) ~= 1 then
		return 0
	end
	
	if self:GetUnit(nRow, nCol) > 0 then
		return 0
	end
	return 1

end

function Maze:ClearUnit(nRow, nCol)
	if self.tbUnit[nRow] then
		self.tbUnit[nRow][nCol] = 0
	end
end

function Maze:SetUnit(nRow, nCol, dwId)
	if self.tbUnit[nRow] then
		self.tbUnit[nRow][nCol] = dwId
	end
	Event:FireEvent("SetUnit", nRow, nCol, dwId)
end

function Maze:GetUnit(nRow, nCol)
	if self.tbUnit[nRow] then
		return self.tbUnit[nRow][nCol]
	end
end

function Maze:IsFree(nRow, nCol)
	if nRow > Def.MAZE_ROW_COUNT then
		return 0
	end
	if self.tbData[nRow][nCol] ~= MAP_BLOCK then
		return 1
	end
	return 0
end

function Maze:SetMouseMonster(dwMonsterTemplateId)
	self.dwMonsterTemplateId = dwMonsterTemplateId
	Event:FireEvent("SetMouseMonster", dwMonsterTemplateId)
end

function Maze:GetMouseMonster()
	return self.dwMonsterTemplateId
end

function Maze:ClearMouseMonster()
	self.dwMonsterTemplateId = nil
	Event:FireEvent("ClearMouseMonster")
end
--Render Maze

function Maze:GenBlock()
	local BlockNode = CCSpriteBatchNode:create(Def.szBlockImg)
    local tbSprite = {}
    self.tbBlock = {}
    local tbSize = self:GetSize()
    local nStartX = -tbSize.width / 2 + Def.BLOCK_WIDTH / 2
    local nStartY = -tbSize.height / 2 + Def.BLOCK_HEIGHT / 2
    for nRow, tbRow in ipairs(self.tbData) do
    	self.tbBlock[nRow] = {}
		for nColumn, nData in ipairs(tbRow) do
			local pSprite = CCSprite:createWithTexture(BlockNode:getTexture())
			self.tbBlock[nRow][nColumn] = pSprite
			local nX, nY = nStartX + (nColumn - 1) * Def.BLOCK_WIDTH, nStartY + (nRow - 1) * Def.BLOCK_HEIGHT
    		pSprite:setPosition(nX, nY)
    		tbSprite[#tbSprite + 1] = pSprite
			if nData ~= MAP_BLOCK then
				pSprite:setVisible(false)
	    	end
		end
	end

	return tbSprite
end
