--===================================================
-- File Name    : hero.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-08-07 13:09:07
-- Description  :
-- Modify       :
--===================================================

local frameWidth = 36
local frameHeight = 48

-- create hero animate
local textureHero = CCTextureCache:sharedTextureCache():addImage(Def.szHeroFile)
local rect = CCRectMake(0, frameHeight, frameWidth, frameHeight)
local frame0 = CCSpriteFrame:createWithTexture(textureHero, rect)
    
if not Hero.tbHeroClass then
	Hero.tbHeroClass = Lib:NewClass(Character)
end

local Id = 0
local function Accumulator()
	Id = Id + 1
	return Id
end

local tbHeroClass = Hero.tbHeroClass

function Hero:NewHero(nStartX, nStartY, tbProperty, tbAI)
	local tbNewHero = Lib:NewClass(tbHeroClass)
    local pHero = CCSprite:createWithSpriteFrame(frame0)
    pHero:setPosition(nStartX, nStartY)
    pHero.isPaused = true
    tbNewHero.dwId = Accumulator()
	tbNewHero:Init(pHero, tbProperty, tbAI)
	GameMgr:AddCharacter(tbNewHero.dwId, tbNewHero)
	return tbNewHero, pHero
end

function tbHeroClass:AutoMove()
	local x, y = self.pSprite:getPosition()

	local function IsArriveTarget()
		if not self.nDirection or not self.tbTarget then
			return 1
		end
		if x == self.tbTarget.x and y == self.tbTarget.y then
			return 1
		end
		return 0
	end

	if IsArriveTarget() == 1 then
		self:RecordPos(x, y)
		local tbMonster, nDirection = self:TryFindMonster()
		if tbMonster then
			self:SetDirection(nDirection)
			self:Attack()
			return 0
		end
		local nNextDir = Def.DIR_END		
		for _, nDir in ipairs(self.tbAIDirection) do
			local tbPosOffset = Def.tbMove[nDir]
			if not tbPosOffset then
				return 0
			end			
			local nX, nY = unpack(tbPosOffset)
			local nNewX, nNewY = x + self.tbSize.width * nX + nX, y + self.tbSize.height * nY
			if self:TryGoto(nNewX, nNewY) == 1 then
				nNextDir = nDir
				self:PushPos(nNextDir)
				break
			end
		end
		if nNextDir == Def.DIR_END then
			nNextDir = self:PopPos()
			if not nNextDir then
				self.pSprite.isPaused = true
				self.nDirection = nil
				self.tbTarget = nil
			end
		end
		self:Goto(x, y, nNextDir)
	end

	local nDirection = self.nDirection
	self:Move(nDirection)
end

function tbHeroClass:TryFindMonster()
	local nFindRange = self.tbProperty.AttackRange
	local nRow, nCol = self:GetLogicPos()
	
	for nDirection = Def.DIR_START + 1, Def.DIR_END - 1 do
		local tbPosOffset = Def.tbMove[nDirection]
		if not tbPosOffset then
			return
		end
		for i = 1, nFindRange do
			local nX, nY = unpack(tbPosOffset)
			nX = nX * i
			nY = nY * i
			local nCheckRow, nCheckCol = nRow + nY, nCol + nX
			if Maze:IsFree(nCheckRow, nCheckCol) ~= 1 then
				break
			end
			local dwId = Maze:GetUnit(nCheckRow, nCheckCol)
			if dwId > 0 and Lib:IsHero(dwId) ~= 1 then
				cclog("find Monster")
				return GameMgr:GetCharacterById(dwId), nDirection
			end
		end
	end
end

function tbHeroClass:TryGoto(nNewX, nNewY)
	if self:IsExplored(nNewX, nNewY) == 1 then
		return 0
	end
	if Maze:CanMove(nNewX, nNewY) ~= 1 then
		return 0
	end
	
    return 1
end

function tbHeroClass:RecordPos(nX, nY)
	if not self.tbRecordPos[nX] then
		self.tbRecordPos[nX] = {}
	end
 
	self.tbRecordPos[nX][nY] = 1
end

function tbHeroClass:IsExplored(nX, nY)
	if self.tbRecordPos[nX] then
		return self.tbRecordPos[nX][nY]
	end
	return nil
end

function tbHeroClass:PushPos(nDir)
	if not nDir then
		return 0
	end
	local nOppDir = self:GetOppositeDirection(nDir)
	table.insert(self.tbStack, nOppDir)
	return 1
end

function tbHeroClass:PopPos()
	if #self.tbStack == 0 then
		return
	end
	local nDir = self.tbStack[#self.tbStack]
	self.tbStack[#self.tbStack] = nil
	return nDir
end
    