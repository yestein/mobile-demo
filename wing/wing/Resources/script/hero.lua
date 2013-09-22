--===================================================
-- File Name    : hero.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-08-07 13:09:07
-- Description  :
-- Modify       :
--===================================================

if not Hero.tbHeroClass then
	Hero.tbHeroClass = Lib:NewClass(Character)
end

local Id = 0
function Accumulator()
	Id = Id + 1
	return Id
end

local tbHeroClass = Hero.tbHeroClass

function Hero:Init()
	self.tbHero = {}
end

function Hero:Start()
	for dwId, tbHero in pairs(self.tbHero) do
		tbHero:Start()
	end
end

function Hero:Reset()
	for dwId, tbHero in pairs(self.tbHero) do
		tbHero:Reset()
	end
end

function Hero:NewHero(pSprite, tbProperty, tbAI)
	local tbNewHero = Lib:NewClass(tbHeroClass)
	tbNewHero:Init(pSprite, tbProperty, tbAI)
	tbNewHero.dwId = Accumulator()
	self.tbHero[#self.tbHero + 1] = tbNewHero
	return tbNewHero
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
		
		if self:TryFindMonster() == 1 then
			self:SetDirection(nDir)
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

function tbHeroClass:Attack()
	local nX, nY = spriteHero:getPosition()
	Bullet:AddBullet(nX, nY, self.nDirection)
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
    