--===================================================
-- File Name    : maze.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-08-07 13:06:47
-- Description  :
-- Modify       :
--===================================================

Maze.MAP_FREE     = 1
Maze.MAP_BLOCK    = 2

Maze.MAP_MONSTER_START  = 3
Maze.MAP_TARGET = 99999

function Maze:Init(nWidth, nHeight)
	self.tbData = {}
	self.tbUnit = {}
	self.tbRecord = {}
	self.tbMapTargetPos = {Def.tbEntrance[1], Def.tbEntrance[2]}
	for i = 1, nWidth do
		self.tbData[i] = {}
		self.tbUnit[i] = {}
		for j = 1, nHeight do
			if i == Def.tbEntrance[1] and j == Def.tbEntrance[2] then
				self.tbData[i][j] = self.MAP_TARGET + Maze.MAP_MONSTER_START - 1
			else
				self.tbData[i][j] = self.MAP_BLOCK
			end
			self.tbUnit[i][j] = {}
		end
	end
end

function Maze:Reset()
	for nX , tb in ipairs(self.tbData) do
		for nY, _ in ipairs(tb) do
			self:SetData(nX, nY, self.MAP_BLOCK)
		end
	end
	local nEnterX, nEnterY = unpack(Def.tbEntrance)
	self:SetData(nEnterX, nEnterY, self.MAP_TARGET + Maze.MAP_MONSTER_START - 1)
	Event:FireEvent("ResetMaze")
end

function Maze:Entry(tbData)
	for nY, tbRow in ipairs(tbData) do
		for nX, nData in ipairs(tbRow) do
			if nY == Def.MAZE_LOGIC_HEIGHT and nX == Def.MAZE_LOGIC_WIDTH / 2 then
				self.tbData[nX][nY] = self.MAP_FREE
			else
				self.tbData[nX][nY] = nData
			end
		end
	end
	return 1
end

function Maze:GetAllData()
	return self.tbData
end

function Maze:GetData(nX, nY)
	if self.tbData[nX] then
		return self.tbData[nX][nY]
	end
	return self.MAP_BLOCK
end

function Maze:SetData(nX, nY, nValue)
	self.tbData[nX][nY] = nValue
	local pBlock = self.tbBlock[nX][nY]
	if not pBlock then
		return 0
	end
	if nValue == self.MAP_BLOCK then
		pBlock:setVisible(true)
	else
		pBlock:setVisible(false)
	end
end

function Maze:Load()
	Event:FireEvent("StartLoadMaze")
	local szPath = CCFileUtils:sharedFileUtils():getWritablePath()
	local file = io.open(szPath.."savemap.lua", "r")
	if not file then
		return
	end
	local t = dofile(szPath.."savemap.lua")
	Event:FireEvent("LoadMazeSuccess")
end

function Maze:SetSkillTest()
	local nWidth , nHeight = Def.MAZE_LOGIC_WIDTH, Def.MAZE_LOGIC_HEIGHT
	for nX = 1, nWidth do
		for nY = 1, nHeight do
			if nY == 1 or nY == nHeight or nX == 1 or nX == nWidth or nX == 15 or nX == 27 or nY == 10 then
				self:SetData(nX, nY, self.MAP_BLOCK)
			else
				self:SetData(nX, nY, self.MAP_FREE)
			end
			self.tbUnit[nX][nY] = {}
		end
	end
end

function Maze:Refresh()
	for nX, tb in ipairs(self.tbBlock) do
		for nY, pSprite in ipairs(tb) do
			if self:GetData(nX, nY) == self.MAP_BLOCK then
				pSprite:setVisible(true)
			else
				pSprite:setVisible(false)
			end
		end
	end
end

function Maze:GetSize()
	return self.tbSize
end

function Maze:SetSize(tbSize)
	self.tbSize = {width = tbSize.width, height = tbSize.height}
end

function Maze:Save()
	Event:FireEvent("StartSaveMaze")
    local szPath = CCFileUtils:sharedFileUtils():getWritablePath()
	local file = assert(io.open(szPath.."savemap.lua", "w"))
	file:write("Maze:Entry{\n")
	for nY = 1, Def.MAZE_LOGIC_HEIGHT do
		file:write("{")
		for nX = 1, Def.MAZE_LOGIC_WIDTH do
			local nData = self:GetData(nX, nY)
			file:write(string.format("%d, ", nData))
		end
		file:write("},\n")
	end
	file:write("}")
	file:close()
	Event:FireEvent("SaveMazeSuccess")
end

function Maze:Dig(nX, nY)
	local bRet, szMsg = self:CheckCanDig(nX, nY)
	if bRet ~= 1 then
		if szMsg then
			GameMgr:SysMsg(szMsg, "red")
		end
		return 0
	end	
	self:SetData(nX, nY, self.MAP_FREE)
    self:PushUndoPos(nX, nY)
    Event:FireEvent("Dig", nX, nY)
    return 1
end

function Maze:UnDoDig()
	local tbPos, _ = self:GetLastPos()
	if not tbPos then
		return 0
	end
	
	self:PopUndoPos()
	local nX, nY = unpack(tbPos)
	self:SetData(nX, nY, self.MAP_BLOCK)
	Event:FireEvent("UnDoDig", nX, nY)
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
	local nX, nY = unpack(tbPos)
	self:SetData(nX, nY, self.MAP_FREE)
    local bReDo = 1
    Event:FireEvent("Dig", nX, nY, bReDo)
    return 1
end

function Maze:PutMonster(nX, nY, dwMonsterTemplateId)
	if self:GetData(nX, nY) ~= self.MAP_FREE then
		return 0
	end
	self:SetData(nX, nY, self.MAP_MONSTER_START + dwMonsterTemplateId - 1)
	Event:FireEvent("PutMonster", dwMonsterTemplateId, nX, nY)
	return 1
end

function Maze:MoveMonster(dwId, nX, nY, nNewX, nNewY)
	if not nX or not nY or not nNewX or not nNewY then
		assert(false)
		return
	end
	self:ClearUnit(nX, nY, dwId)
	self:SetUnit(nNewX, nNewY, dwId)
	if GameMgr:GetState() == GameMgr.STATE_EDIT then
		local nMazeData = self:GetData(nX, nY)
		if nMazeData >= self.MAP_MONSTER_START then
			self:SetData(nNewX, nNewY, nMazeData)
			self:SetData(nX, nY, self.MAP_FREE)
			if nMazeData - self.MAP_MONSTER_START + 1 == self.MAP_TARGET then
				self.tbMapTargetPos[1] = nNewX
				self.tbMapTargetPos[2] = nNewY
			end
		else
			assert(false)
		end		
	end
	local tbCharacter = GameMgr:GetCharacterById(dwId)
	if not tbCharacter then
		assert(false)
		return
	end
	tbCharacter:SetLogicPos(nNewX, nNewY)
	Event:FireEvent("MoveMonster", dwId, nX, nY, nNewX, nNewY)
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

function Maze:PushUndoPos(nX, nY)
	if nX and nY then
		self.nIndex = self.nIndex + 1
		self.tbRecordPos[self.nIndex] = {nX, nY}
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

function Maze:CheckCanDig(nX, nY)
	local tbCheckPos = {
		{nX - 1, nY},
		{nX + 1, nY},
		{nX, nY - 1},
		{nX, nY + 1},
	}

	if nY > Def.MAZE_LOGIC_HEIGHT then
		return 0
	end

	if self:GetData(nX, nY) ~= self.MAP_BLOCK then
		return 0
	end

	local nDigPoint = Player:GetResouce("DigPoint")
	if nDigPoint <= 0 then
		return 0, "挖掘点不足"
	end
	local bLogicCheck = 0
	for _, tbPos in ipairs(tbCheckPos) do
		local nValue = self:GetData(tbPos[1], tbPos[2])
		if nValue and nValue ~= self.MAP_BLOCK then
			bLogicCheck = 1
			break
		end
	end
	if bLogicCheck ~= 1 then
		return 0, "必须沿着通道挖掘"
	end
	return 1
end

function Maze:RandomMaze()
	for nX, tb in ipairs(self.tbData) do
		for nY, _ in ipairs(tbRow) do
			self:SetData(math.random(1, 2))
		end
	end
end

function Maze:CanMove(nX, nY)
	if self:IsFree(nX, nY) ~= 1 then
		return 0
	end
	return 1

end

function Maze:ClearUnit(nX, nY, dwId)
	if self.tbUnit[nX] then
		self.tbUnit[nX][nY][dwId] = nil
	end
end

function Maze:SetUnit(nX, nY, dwId)
	self.tbUnit[nX][nY][dwId] = 1
	Event:FireEvent("SetUnit", nX, nY, dwId)
end

function Maze:GetUnit(nX, nY)
	if self.tbUnit[nX] and self.tbUnit[nX][nY] then
		return self.tbUnit[nX][nY]
	end
	return {}
end

function Maze:GetRandomUnit(nX, nY)
	local dwRetId = nil
	if self.tbUnit[nX] and self.tbUnit[nX][nY] then
		 for dwId, _ in pairs(self.tbUnit[nX][nY]) do
		 	dwRetId = dwId
		 	break
		 end
	end
	return dwRetId
end

function Maze:IsFree(nX, nY)
	if nX <= 0 or nX > Def.MAZE_LOGIC_WIDTH or nY <= 0  or nY > Def.MAZE_LOGIC_HEIGHT then
		return 0
	end
	if self:GetData(nX, nY) ~= self.MAP_BLOCK then
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
    for nX, tb in ipairs(self.tbData) do
    	self.tbBlock[nX] = {}
		for nY, nData in ipairs(tb) do
			local pSprite = CCSprite:createWithTexture(BlockNode:getTexture())
			self.tbBlock[nX][nY] = pSprite
			local nX, nY = nStartX + (nX - 1) * Def.BLOCK_WIDTH, nStartY + (nY - 1) * Def.BLOCK_HEIGHT
    		pSprite:setPosition(nX, nY)
    		tbSprite[#tbSprite + 1] = pSprite
			if nData ~= self.MAP_BLOCK then
				pSprite:setVisible(false)
	    	end
		end
	end
	return tbSprite
end

function Maze:Debug()
	if not self.bDebug then
		self.bDebug = true
	else
		self.bDebug = false
	end
	for nX, tb in pairs(self.tbUnit) do
		for nY, tbList in pairs(tb) do
			local szList = ""
			for dwId, _ in pairs(tbList) do
				szList = szList .. " ".. dwId
			end
			if szList ~= "" then
				print(nX, nY, szList)
			end
		end
	end
end

function Maze:GetBlock(nX, nY)
	if self.tbBlock[nX] and self.tbBlock[nX][nY] then
		return self.tbBlock[nX][nY]
	end
end

function Maze:HideAllBlock()
	for _, tb in pairs(self.tbBlock) do
		for _, pSprite in pairs(tb) do
			pSprite:setVisible(false)
		end
	end
end

function Maze:StartDrag(nX, nY)
	if not self.tbDrag then
		local dwCharacterId = self:GetRandomUnit(nX, nY)
		if not dwCharacterId then
			return
		end
		local tbCharacter = GameMgr:GetCharacterById(dwCharacterId)
		if not tbCharacter then
			return
		end
		self.tbDrag = {
			nLogicX = nX, 
			nLogicY = nY,
			pSprite = tbCharacter.pSprite,
			dwId = dwCharacterId,
			isPause = tbCharacter.pSprite.isPaused,
		}
		tbCharacter:Pause()
	end
end

function Maze:GetDragInfo()
	return self.tbDrag
end

function Maze:StopDrag(nX, nY)
	local bRet = 0
	if self:GetData(nX, nY) == self.MAP_FREE then
		self:MoveMonster(self.tbDrag.dwId, self.tbDrag.nLogicX, self.tbDrag.nLogicY, nX, nY)
		bRet = 1
	end
	if self.tbDrag.isPause == false then
		local tbCharacter = GameMgr:GetCharacterById(self.tbDrag.dwId)
		if not tbCharacter then
			assert(false)
			return
		end
		tbCharacter:CancelPause()
	end
	self.tbDrag = nil
	return bRet
end