--=======================================================================
-- File Name    : ai.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-12-06 23:11:12
-- Description  :
-- Modify       :
--=======================================================================

require("define")

if not AI then
	AI = {}
end
local tbDefaultDirection = {Def.DIR_DOWN, Def.DIR_RIGHT, Def.DIR_UP, Def.DIR_LEFT}

function AI:GetCfg(szAIName)
	return self.tbCfg[szAIName]
end

function AI:GetDirctionList(szAIName)
	local tbRet = nil
	if self.tbCfg[szAIName] then
		tbRet = self.tbCfg[szAIName].tbDirection
	end
	if not tbRet then
		tbRet = tbDefaultDirection
	end
	return tbRet
end

function AI.AI_HeroExplore(tbHero)
	local self = tbHero
	local nNextDir = Def.DIR_END
	local tbCatchList = self:GetCatchList()
	local tbMonster, nDirection = self:TryFindMonster(tbCatchList)
	if tbMonster then
		if tbMonster:GetTemplateId() == Maze.MAP_TARGET then
			local bCatch = self:GoAndCatch(nDirection, tbMonster)
			if bCatch == 1 then
				self:Finish()
				self:SetDirection(Lib:GetOppositeDirection(self.nDirection))
				nNextDir = self:PopPos()
				self:Goto(nNextDir)
				--TODO Other Heros
			else
				self:PushPos(nDirection)
			end
		else
			local bAttack = self:GoAndAttack(nDirection, tbMonster)
			if bAttack == 0 then
				self:PushPos(nDirection)
			end
		end
		return 1
	end
	if self:IsFinish() ~= 1 then
		local x, y = self.pSprite:getPosition()
		self:RecordPos(x, y)
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
	end
	if nNextDir == Def.DIR_END then
		nNextDir = self:PopPos()
		if not nNextDir then
			self.pSprite.isPaused = true
			self.nDirection = nil
			self.tbTarget = nil
			if self:IsFinish() == 1 then
				GameMgr:SetState(GameMgr.STATE_NORMAL)
			end
			return
		end
	end
	self:Goto(nNextDir)
end

function AI.AI_NormalMove(tbCharacter)
	
	local self = tbCharacter
	local x, y = self.pSprite:getPosition()
	local tbCatchList = self:GetCatchList()
	local tbHero, nDirection = self:TryFindHero(tbCatchList)
	if tbHero then
		self:GoAndAttack(nDirection, tbHero)
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
				self:Goto(nNextDir)
				break
			end
		end
	end
end

function AI.AI_NotMove(tbCharacter)
	local self = tbCharacter
	local tbHero, nDirection, nX, nY = self:TryFindHero(self:GetCatchList())
	if tbHero then
		self:GoAndAttack(nDirection, tbHero)
		return 0
	end
	return 1
end

function AI.AI_Follow(tbCharacter)
	local self = tbCharacter
	local dwMasterId = self:GetMasterId()
	if not dwMasterId or dwMasterId <= 0 then
		return 0
	end
	return 1
end


AI.tbCfg = {
	["HeroExplore"] = {
		tbDirection = tbDefaultDirection,
		aifunc = AI.AI_HeroExplore,
	},
	["NormalMove"] = {
		tbDirection = tbDefaultDirection,
		aifunc = AI.AI_NormalMove,
	},
	["NotMove"] = {
		tbDirection = {},
		aifunc = AI.AI_NotMove,
	},
	["Follow"] = {
		tbDirection = {},
		aifunc = AI.AI_Follow,
	},
}