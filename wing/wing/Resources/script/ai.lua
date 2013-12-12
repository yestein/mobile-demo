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

function AI.AI_NormalMove(tbCharacter)
	-- 
	local x, y = tbCharacter.pSprite:getPosition()
	local tbHero, nDirection = tbCharacter:TryFindHero()
	if tbHero then
		tbCharacter:GoAndAttack(nDirection, tbHero)
		return 0
	end
	
	local nStep = 1
	local nRandom = math.random(1, 2)
	if nRandom == 2 then
		nStep = -1
	end
	local nTryDirction = tbCharacter.nDirection
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
			local nNewX, nNewY = x + tbCharacter.tbSize.width * nX + nX, y + tbCharacter.tbSize.height * nY
			if tbCharacter:TryGoto(nNewX, nNewY) == 1 then
				tbCharacter:Goto(nNextDir)
				break
			end
		end
	end
end

function AI.AI_NotMove(tbCharacter)
	local tbHero, nDirection, nX, nY = tbCharacter:TryFindHero()
	if tbHero then
		tbCharacter:GoAndAttack(nDirection, tbHero)
		return 0
	end
	return 1
end

AI.tbCfg = {
	["NormalMove"] = {
		tbDirection = tbDefaultDirection,
		aifunc = AI.AI_NormalMove,
	},
	["NotMove"] = {
		tbDirection = {},
		aifunc = AI.AI_NotMove,
	},
}