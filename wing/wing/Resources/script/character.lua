--=======================================================================
-- 文件名　：character.lua
-- 创建者　：yulei(yulei1@kingsoft.com)
-- 创建时间：2013-09-22 19:57:43
-- 功能描述：
-- 修改列表：
--=======================================================================


function Character:Init(pSprite, tbProperty, tbAI)
	self.pSprite = pSprite
	local nOriginX, nOriginY = pSprite:getPosition()
	self.tbOrigin = {x = nOriginX, y = nOriginY}
	local nRow, nCol = Lib:GetRowColByPos(nOriginX, nOriginY)
	self.tbLogicPos = {nRow = nRow, nCol = nCol}
	Maze:SetUnit(nRow, nCol, self.dwId)
	
	self.tbSize = {width = 36, height = 48}
	self.tbStack = {}
	self.nWaitFrame = 0
	self.tbRecordPos = {}
	self.tbProperty = {
		CurHP = 100,
		MaxHP = 100,
		CurMP = 100,
		MaxMP = 100,
		Attack = 5,
		AttackRange = 1,
		Defence = 5,
		Magic = 5,
		Speed = 1,		
	}
	self.tbAIDirection = tbAI or {Def.DIR_DOWN, Def.DIR_RIGHT, Def.DIR_UP, Def.DIR_LEFT}
	if tbProperty then
		for k, v in pairs(tbProperty) do
			if self:SetProperty(k, v) ~= 1 then
				print(k, v)
			end
		end
	end
	
	self:SetDirection(Def.DIR_DOWN)
	-- moving Hero at every frame
	local function tick()
	    if pSprite.isPaused then
	    	return
	    end
	    if self.nWaitFrame > 0 then
	    	self.nWaitFrame = self.nWaitFrame - 1
	    	return
	    end
	    self:AutoMove()
	end
	self.nRegId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0, false)
end

function Character:Uninit()
	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.nRegId)
end

function Character:Attack()
	local nX, nY = self.pSprite:getPosition()
	local tbBulletProperty = {
		Damage = self:GetProperty("Attack"),
	}
	local tbPosOffset = Def.tbMove[self.nDirection]
	local nOffsetX, nOffsetY = unpack(tbPosOffset)
	nOffsetX = nOffsetX * 36
	nOffsetY = nOffsetY * 48
	Bullet:AddBullet(nX + nOffsetX, nY + nOffsetY, self.nDirection, tbBulletProperty)
	self:Wait(60)
end

function Character:BeAttacked(tbBullet)
	local nCurHP = self:GetProperty("CurHP")
	local nNewHP = tbBullet:CalcDamage(self)
	self:SetProperty("CurHP", nNewHP)
	if nNewHP <= 0 then
		self:Die()
	end
end

function Character:Die()
	Maze:ClearUnit(self.tbLogicPos.nRow, self.tbLogicPos.nCol)
	GameMgr:RemoveCharacter(self.dwId)
	self:Uninit()
end

function Character:Wait(nFrame)
	self.nWaitFrame = nFrame
end

function Character:Start()
	self.tbStack = {}
	self.tbRecordPos = {}
	self.pSprite.isPaused = false
end

function Character:Reset()
	self.tbStack = {}
	self.tbRecordPos = {}
	self.nDirection = nil
	self.tbTarget = nil
	self.pSprite.isPaused = true

    self.pSprite:setPosition(self.tbOrigin.x, self.tbOrigin.y)
    self:SetDirection(Def.DIR_DOWN)
end

function Character:GetProperty(Key)
	if not self.tbProperty[Key] then
		return -1
	else
		return self.tbProperty[Key]
	end
end

function Character:SetProperty(Key, Value)
	if self.tbProperty[Key] then
		self.tbProperty[Key] = Value
		return 1
	end
	return 0
end

function Character:GetOppositeDirection(nDir)
	if nDir == Def.DIR_DOWN then
		return Def.DIR_UP
	elseif nDir == Def.DIR_RIGHT then
		return Def.DIR_LEFT
	elseif nDir == Def.DIR_LEFT then
		return Def.DIR_RIGHT
	elseif nDir == Def.DIR_UP then
		return Def.DIR_DOWN
	end
end

function Character:Move(nDirection)
	local tbPosOffset = Def.tbMove[nDirection]
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

function Character:Goto(x, y, nDir)
	local tbPosOffset = Def.tbMove[nDir]
	if not tbPosOffset then
		return 0
	end
	local nX, nY = unpack(tbPosOffset)
	Maze:ClearUnit(self.tbLogicPos.nRow, self.tbLogicPos.nCol)
	self.tbLogicPos.nRow = self.tbLogicPos.nRow + nY
	self.tbLogicPos.nCol = self.tbLogicPos.nCol + nX
	Maze:SetUnit(self.tbLogicPos.nRow, self.tbLogicPos.nCol, self.dwId)
	local nNewX, nNewY = x + self.tbSize.width * nX + nX, y + self.tbSize.height * nY
	self:SetDirection(nDir)
    self.tbTarget = {x = nNewX, y = nNewY}
end

function Character:SetDirection(nDirection)
	if self.nDirection ~= nDirection then
		self.nDirection = nDirection
		
		local frameWidth = 36
    	local frameHeight = 48

    	local Texture = self.pSprite:getTexture()
		local rect = CCRectMake(0, frameHeight * Def.tbTextureRow[nDirection], frameWidth, frameHeight)
	    local frame0 = CCSpriteFrame:createWithTexture(Texture, rect)
	    rect = CCRectMake(frameWidth, frameHeight * Def.tbTextureRow[nDirection], frameWidth, frameHeight)
	    local frame1 = CCSpriteFrame:createWithTexture(Texture, rect)
	    rect = CCRectMake(2 * frameWidth, frameHeight * Def.tbTextureRow[nDirection], frameWidth, frameHeight)
	    local frame2 = CCSpriteFrame:createWithTexture(Texture, rect)
	    rect = CCRectMake(3 * frameWidth, frameHeight * Def.tbTextureRow[nDirection], frameWidth, frameHeight)
	    local frame3 = CCSpriteFrame:createWithTexture(Texture, rect)
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

function Character:AutoMove()
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
		local nNextDir = math.random(Def.DIR_START + 1, Def.DIR_END - 1)
		local tbPosOffset = Def.tbMove[nNextDir]
		if not tbPosOffset then
			return 0
		end			
		local nX, nY = unpack(tbPosOffset)
		local nNewX, nNewY = x + self.tbSize.width * nX + nX, y + self.tbSize.height * nY
		if self:TryGoto(nNewX, nNewY) == 0 then
			return
		end
		self:Goto(x, y, nNextDir)
	end

	local nDirection = self.nDirection
	self:Move(nDirection)
end

function Character:TryGoto(nNewX, nNewY)
	if Maze:CanMove(nNewX, nNewY) ~= 1 then
		return 0
	end
	
    return 1
end

function Character:GetLogicPos()
	return self.tbLogicPos.nRow, self.tbLogicPos.nCol
end
