--===================================================
-- File Name    : hero.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-08-07 13:09:07
-- Description  :
-- Modify       :
--===================================================

local Id = 1
local function Accumulate(nId)
	if nId then
		Id = nId
	else
		Id = Id + 1
	end
	return Id
end

Hero.DIR_DOWN = Accumulate()
Hero.DIR_RIGHT = Accumulate()
Hero.DIR_UP = Accumulate()
Hero.DIR_LEFT = Accumulate()


Hero.tbMove = {
	[Hero.DIR_UP] = {0, 1},
	[Hero.DIR_DOWN] = {0, -1},
	[Hero.DIR_LEFT] = {-1, 0},
	[Hero.DIR_RIGHT] = {1, 0},
}

Hero.tbTextureRow = {
	[Hero.DIR_DOWN] = 0,
	[Hero.DIR_LEFT] = 1,
	[Hero.DIR_UP] = 2,
	[Hero.DIR_RIGHT] = 3,
}

DIR_NAME = {
	[Hero.DIR_UP] = "UP",
	[Hero.DIR_DOWN] = "DOWN",
	[Hero.DIR_LEFT] = "LEFT",
	[Hero.DIR_RIGHT] = "RIGHT",
}

function Hero:Init(pSprite, tbProperty, tbAI)
	self.pSprite = pSprite
	local nOriginX, nOriginY = pSprite:getPosition()
	self.tbOrigin = {x = nOriginX, y = nOriginY}
	self.tbSize = {width = 36, height = 48}
	self.tbStack = {}
	self.tbRecordPos = {}
	self.tbProperty = {
		CurHP = 1,
		MaxHP = 1,
		CurMP = 1,
		MaxMP = 1,
		Attack = 1,
		Defence = 1,
		Magic = 1,
		Speed = 1,
	}
	self.tbAIDirection = tbAI or {self.DIR_DOWN, self.DIR_RIGHT, self.DIR_UP, self.DIR_LEFT}
	for k, v in pairs(tbProperty) do
		if self:SetProperty(k, v) ~= 1 then
			print(k, v)
		end
	end
	
	self:SetDirection(self.DIR_DOWN)
	-- moving Hero at every frame
	local function tick()
	    if pSprite.isPaused then
	    	return
	    end
	    self:AutoMove()
	end
	CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0, false)
end

function Hero:Start()
	self.tbStack = {}
	self.tbRecordPos = {}
	self.pSprite.isPaused = false
end

function Hero:Reset()
	self.tbStack = {}
	self.tbRecordPos = {}
	self.nDirection = nil
	self.tbTarget = nil
	self.pSprite.isPaused = true

    self.pSprite:setPosition(self.tbOrigin.x, self.tbOrigin.y)
end

function Hero:SetProperty(Key, Value)
	if self.tbProperty[Key] then
		self.tbProperty[Key] = Value
		return 1
	end
	return 0
end

function Hero:AutoMove()
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
		local nNextDir = self.DIR_END
		for _, nDir in ipairs(self.tbAIDirection) do
			local tbPosOffset = self.tbMove[nDir]
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
		if nNextDir == self.DIR_END then
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

function Hero:TryGoto(nNewX, nNewY)
	if Hero:IsExplored(nNewX, nNewY) == 1 then
		return 0
	end
	if Maze:CanMove(nNewX, nNewY) ~= 1 then
		return 0
	end
	
    return 1
end

function Hero:GetOppositeDirection(nDir)
	if nDir == self.DIR_DOWN then
		return self.DIR_UP
	elseif nDir == self.DIR_RIGHT then
		return self.DIR_LEFT
	elseif nDir == self.DIR_LEFT then
		return self.DIR_RIGHT
	elseif nDir == self.DIR_UP then
		return self.DIR_DOWN
	end
end

function Hero:Move(nDirection)
	local tbPosOffset = self.tbMove[nDirection]
	if not tbPosOffset then
		return 0
	end
	local nX, nY = unpack(tbPosOffset)
	local x, y = self.pSprite:getPosition()
	local nNewX, nNewY = x + nX * self.tbProperty.Speed, y + nY * self.tbProperty.Speed
	if self.tbTarget.x == nNewX then
		if (nY > 0 and nNewY > self.tbTarget.y) or (nY < 0 and nNewY < self.tbTarget.y) then
			nNewY = self.tbTarget.y
		end
	elseif self.tbTarget.y == nNewY then
		if (nX > 0 and nNewX > self.tbTarget.x) or (nX < 0 and nNewX < self.tbTarget.x) then
			nNewX = self.tbTarget.x
		end
	end
	self.pSprite:setPosition(nNewX, nNewY)
end

function Hero:Goto(x, y, nDir)
	local tbPosOffset = self.tbMove[nDir]
	if not tbPosOffset then
		return 0
	end
	local nX, nY = unpack(tbPosOffset)
	local nNewX, nNewY = x + self.tbSize.width * nX + nX, y + self.tbSize.height * nY
	self:SetDirection(nDir)
    self.tbTarget = {x = nNewX, y = nNewY}
end

function Hero:SetDirection(nDirection)
	if self.nDirection ~= nDirection then
		self.nDirection = nDirection
		
		local frameWidth = 36
    	local frameHeight = 48

    	local textureHero = self.pSprite:getTexture()
		local rect = CCRectMake(0, frameHeight * self.tbTextureRow[nDirection], frameWidth, frameHeight)
	    local frame0 = CCSpriteFrame:createWithTexture(textureHero, rect)
	    rect = CCRectMake(frameWidth, frameHeight * self.tbTextureRow[nDirection], frameWidth, frameHeight)
	    local frame1 = CCSpriteFrame:createWithTexture(textureHero, rect)
	    rect = CCRectMake(2 * frameWidth, frameHeight * self.tbTextureRow[nDirection], frameWidth, frameHeight)
	    local frame2 = CCSpriteFrame:createWithTexture(textureHero, rect)
	    rect = CCRectMake(3 * frameWidth, frameHeight * self.tbTextureRow[nDirection], frameWidth, frameHeight)
	    local frame3 = CCSpriteFrame:createWithTexture(textureHero, rect)
		local animFrames = CCArray:create()

	    animFrames:addObject(frame0)
	    animFrames:addObject(frame1)
	    animFrames:addObject(frame2)
	    animFrames:addObject(frame3)

	    local animation = CCAnimation:createWithSpriteFrames(animFrames, 0.15)
	    local animate = CCAnimate:create(animation)
	    self.pSprite:stopAllActions()
	    self.pSprite:runAction(CCRepeatForever:create(animate))
	end
end

function Hero:RecordPos(nX, nY)
	if not self.tbRecordPos[nX] then
		self.tbRecordPos[nX] = {}
	end

	self.tbRecordPos[nX][nY] = 1
end

function Hero:IsExplored(nX, nY)
	if self.tbRecordPos[nX] then
		return self.tbRecordPos[nX][nY]
	end
	return nil
end

function Hero:PushPos(nDir)
	if not nDir then
		return 0
	end
	local nOppDir = self:GetOppositeDirection(nDir)
	table.insert(self.tbStack, nOppDir)
	return 1
end

function Hero:PopPos()
	if #self.tbStack == 0 then
		return
	end
	local nDir = self.tbStack[#self.tbStack]
	self.tbStack[#self.tbStack] = nil
	return nDir
end
    