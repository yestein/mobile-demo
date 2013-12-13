--===================================================
-- File Name    : hero.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-08-07 13:09:07
-- Description  :
-- Modify       :
--===================================================

require("hero_cfg")
local frameWidth = 36
local frameHeight = 48

if not Hero.tbHeroClass then
	Hero.tbHeroClass = Lib:NewClass(Character)
end

local tbHeroClass = Hero.tbHeroClass

function Hero:Init()
	self.nOrginId = 1
	self.nNextId = self.nOrginId 
end

function Hero:Uninit()
	self.nOrginId = 1
	self.nNextId = self.nOrginId 
end

function Hero:GenerateId()
	local nRetId = self.nNextId
	self.nNextId = self.nNextId + 1
	return nRetId
end

function Hero:NewHero(dwHeroTemplateId, nStartX, nStartY, tbAI)
	-- create hero animate
	local tbCfg = self.tbCfg[dwHeroTemplateId]
	local textureHero = CCTextureCache:sharedTextureCache():addImage(tbCfg.szImgFile)
	local rect = CCRectMake(0, frameHeight, frameWidth, frameHeight)
	local frame0 = CCSpriteFrame:createWithTexture(textureHero, rect)
	local tbNewHero = Lib:NewClass(tbHeroClass)
    local pHero = CCSprite:createWithSpriteFrame(frame0)
    pHero:setPosition(nStartX, nStartY)
    pHero.isPaused = true
    tbNewHero.dwId = self:GenerateId()
    local tbProperty = tbCfg.tbProperty
	tbNewHero:Init(pHero, dwHeroTemplateId, tbProperty, tbCfg.tbSkill, tbAI)
	GameMgr:AddCharacter(tbNewHero.dwId, tbNewHero)
	Event:FireEvent("HeroAdd", tbNewHero.dwId)
	return tbNewHero, pHero
end

function Hero:ClearAll()
	for dwId = self.nOrginId, self.nNextId - 1 do
		local tbHero = GameMgr:GetCharacterById(dwId)
		if tbHero then
			tbHero:Die()
		end
	end
	self.nNextId = self.nOrginId 
end

function Hero:GetList()
	local tbRet = {}
	for dwId = self.nOrginId, self.nNextId - 1 do
		local tbHero = GameMgr:GetCharacterById(dwId)
		if tbHero then
			tbRet[dwId] = tbHero
		end
	end
	return tbRet
end

function tbHeroClass:Finish()
	self.bFinish = 1
end

function tbHeroClass:IsFinish()
	return self.bFinish
end

function tbHeroClass:Activate()
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
		local tbMonster, nDirection, nX, nY = self:TryFindMonster()
		if tbMonster then
			self:GoAndAttack(nDirection, tbMonster)
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

				-- GameMgr:SetState(GameMgr.STATE_NORMAL)
				return
			end
		end
		self:Goto(nNextDir)
	end

	self:Move()
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
	local nOppDir = Lib:GetOppositeDirection(nDir)
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
    