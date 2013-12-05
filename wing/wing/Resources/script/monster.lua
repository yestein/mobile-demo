--=======================================================================
-- File Name    : monster.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-09-03 19:49:30
-- Description  :
-- Modify       :
--=======================================================================

require("monster_cfg")

local FRAME_WIDTH = 36
local FRAME_HEIGHT = 48
local INIT_DIRECTION = Def.DIR_DOWN

if not Monster.tbMonsterClass then
	Monster.tbMonsterClass = Lib:NewClass(Character)
end

local tbMonsterClass = Monster.tbMonsterClass

function Monster:Init()
	self.nOrginId = 101
	self.nNextId = self.nOrginId 
end

function Monster:Uninit()
	self.nOrginId = 101
	self.nNextId = self.nOrginId 
end

function Monster:GenerateId()
	local nRetId = self.nNextId
	self.nNextId = self.nNextId + 1
	return nRetId
end


function Monster:NewMonster(dwMonsterTemplateId, nStartX, nStartY)
	local szImgFile = self.tbCfg[dwMonsterTemplateId].szImgFile
	local TextureMonster = CCTextureCache:sharedTextureCache():addImage(szImgFile)
	local InitRect = CCRectMake(0, 0, Def.BLOCK_WIDTH, Def.BLOCK_HEIGHT)
	local MonsterFrame0 = CCSpriteFrame:createWithTexture(TextureMonster, InitRect)
	
	local tbProperty = {CurHP = 15, AttackRange = 3}
	local tbNewMonster = Lib:NewClass(tbMonsterClass)
	local pMonster = CCSprite:createWithSpriteFrame(MonsterFrame0)
	pMonster.isPaused = true
	pMonster:setPosition(nStartX, nStartY)
	tbNewMonster.dwId = self:GenerateId()
    tbNewMonster:Init(pMonster, tbProperty, tbAI)	
    GameMgr:AddCharacter(tbNewMonster.dwId, tbNewMonster)
	Event:FireEvent("MonsterAdd", tbNewMonster.dwId)
	return tbNewMonster, pMonster
end

function Monster:ClearAll()
	for dwId = self.nOrginId, self.nNextId - 1 do
		local tbMonster = GameMgr:GetCharacterById(dwId)
		if tbMonster then
			tbMonster:Die()
		end
	end
	self.nNextId = self.nOrginId 
end

function Monster:GetList()
	local tbRet = {}
	for dwId = self.nOrginId, self.nNextId - 1 do
		local tbMonster = GameMgr:GetCharacterById(dwId)
		if tbMonster then
			tbRet[dwId] = tbMonster
		end
	end
	return tbRet
end

function tbMonsterClass:AutoMove()
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
		local tbHero, nDirection = self:TryFindHero()
		if tbHero then
			self:SetDirection(nDirection)
			self:Attack()
			return 0
		end
		
		local nStep = 1
		local nRandom = math.random(1, 2)
		if nRandom == 2 then
			nStep = -1
		end
		local nTryDirction = self.nDirection
		for i = Def.DIR_START + 1, Def.DIR_END - 1 do
			local nNextDir = nTryDirction + (i - 1) * nStep
			if nNextDir > Def.DIR_END - 1 then
				nNextDir = nNextDir - Def.DIR_END + 1
			elseif nNextDir <  Def.DIR_START + 1 then
				nNextDir = nNextDir + Def.DIR_END - 1
			end
			local tbPosOffset = Def.tbMove[nNextDir]
			if tbPosOffset then
				local nX, nY = unpack(tbPosOffset)
				local nNewX, nNewY = x + self.tbSize.width * nX + nX, y + self.tbSize.height * nY
				if self:TryGoto(nNewX, nNewY) == 1 then
					self:Goto(x, y, nNextDir)
					break
				end
			end
		end
	end
	self:Move(self.nDirection)
end