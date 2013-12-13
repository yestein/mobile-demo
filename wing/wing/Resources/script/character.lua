--=======================================================================
-- File Name    : character.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-09-22 19:57:43
-- Description  :
-- Modify       :
--=======================================================================


function Character:Init(pSprite, dwTemplateId, tbProperty, tbSkill, szAIName)
	self.pSprite = pSprite
	self.dwTemplateId = dwTemplateId
	self.tbCatchRoom = {}
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
		ViewRange   = 5,
		CurHP       = 0,
		MaxHP       = 20,
		CurMP       = 0,
		MaxMP       = 0,
		Attack      = 5,
		AttackRange = 1,
		Defense     = 5,
		Magic       = 5,
		Speed       = 1,
	}
	self.tbAIDirection = AI:GetDirctionList(szAIName)
	self.szAIName = szAIName
	if tbProperty then
		for k, v in pairs(tbProperty) do
			if self:SetProperty(k, v) ~= 1 then
				print(k, v)
			end
		end
	end
	self.tbProperty.CurHP = self.tbProperty.MaxHP
	self.tbProperty.CurMP = self.tbProperty.MaxMP
	self.tbSkill = tbSkill
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
	    self:Activate()
	end
	self.nRegId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0, false)
end

function Character:Uninit()
	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.nRegId)
end

function Character:Start()
	self.tbStack = {}
	self.tbRecordPos = {}
	self.pSprite:setVisible(true)
	self.pSprite.isPaused = false
	Event:FireEvent("CharacterStartMove", self.dwId)
end

function Character:Wait(nFrame)
	self.nWaitFrame = nFrame
end

function Character:Pause()
	self.pSprite.isPaused = true
	Event:FireEvent("CharacterPause", self.dwId)
end

function Character:CancelPause()
	self.pSprite.isPaused = false
	Event:FireEvent("CharacterCancelPause", self.dwId)
end

function Character:Reset()
	self.tbStack = {}
	self.tbRecordPos = {}
	self.nDirection = nil
	self.tbTarget = nil
	self.pSprite.isPaused = true

    self.pSprite:setPosition(self.tbOrigin.x, self.tbOrigin.y)
    self:SetDirection(Def.DIR_DOWN)
    Event:FireEvent("CharacterReset", self.dwId)
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

function Character:GetTemplateId()
	return self.dwTemplateId
end

function Character:GetSkill( )
	-- body
	return self.tbSkill
end

function Character:GoAndAttack(nDirection, tbTarget)
	local nDistance = Lib:GetDistance(self, tbTarget)
	local nAttackRange = self:GetProperty("AttackRange")
	self:SetDirection(nDirection)
	if nAttackRange < nDistance then
		self:Goto(nDirection)
	else
		self:Attack()
	end
end

function Character:Attack()
	local tbSkill = self:GetSkill()
	local szSkillName = tbSkill[math.random(1, #tbSkill)]
	Skill:CastSkill(szSkillName, self)
end

function Character:GoAndCatch(nDirection, tbTarget)
	local nDistance = Lib:GetDistance(self, tbTarget)
	if  nDistance > 1 then
		self:Goto(nDirection)
		return 0
	else
		self:Catch(tbTarget)
		return 1
	end
end

function Character:Catch(tbTarget)
	self.tbCatchRoom[#self.tbCatchRoom + 1] = tbTarget:GetTemplateId()
	tbTarget:Die()
end

function Character:ReceiveDamage(nDamage)
	local nCurHP = self:GetProperty("CurHP")
	local nNewHP = nCurHP - nDamage
	self:SetProperty("CurHP", nNewHP)
	Event:FireEvent("CharacterHPChanged", self.dwId, nCurHP, nNewHP)
	if nNewHP <= 0 then
		self:Die()
	end
end

function Character:Die()
	Event:FireEvent("CharacterDie", self.dwId)
	Maze:ClearUnit(self.tbLogicPos.nRow, self.tbLogicPos.nCol)
	GameMgr:RemoveCharacter("GameScene", self.dwId)
	self:Uninit()
end

function Character:Move()
	if not self.tbTarget then
		return 0
	end

	local nDirection = self.nDirection
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
	Event:FireEvent("CharacterMove", self.dwId, x, y, nNewX, nNewY, nDirection)
end

function Character:Goto(nDir)
	local tbPosOffset = Def.tbMove[nDir]
	if not tbPosOffset then
		return 0
	end
	self:SetDirection(nDir)
	local x, y = self.pSprite:getPosition()
	local nX, nY = unpack(tbPosOffset)
	Maze:ClearUnit(self.tbLogicPos.nRow, self.tbLogicPos.nCol)
	self.tbLogicPos.nRow = self.tbLogicPos.nRow + nY
	self.tbLogicPos.nCol = self.tbLogicPos.nCol + nX
	Maze:SetUnit(self.tbLogicPos.nRow, self.tbLogicPos.nCol, self.dwId)
	local nNewX, nNewY = x + self.tbSize.width * nX + nX, y + self.tbSize.height * nY
	self:SetDirection(nDir)
    self.tbTarget = {x = nNewX, y = nNewY}
    Event:FireEvent("CharacterGoto", self.dwId, x, y, nDir)
end

function Character:SetDirection(nDirection)
	if self.nDirection ~= nDirection then
		self.nDirection = nDirection
		
		Performance:SetSpriteDirection(self.pSprite, nDirection)
	end
end

function Character:Activate()
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
		self:ExecuteAI()
	end
	self:Move()
end

function Character:ExecuteAI()
	local tbCfg = AI:GetCfg(self.szAIName)
	if not tbCfg then
		assert(false)
		return
	end
	local func = tbCfg.aifunc
	if not func then
		print(self.szAIName)
		assert(false)
		return
	end
	return func(self)
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

function Character:TryFindUnit(bHero)
	local nFindRange = self.tbProperty.ViewRange
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
			if dwId > 0 and Lib:IsHero(dwId) == bHero then
				return GameMgr:GetCharacterById(dwId), nDirection, nX, nY
			end
		end
	end
end

function Character:TryFindMonster()
	return self:TryFindUnit(0)
end

function Character:TryFindHero()
	return self:TryFindUnit(1)
end


