--=======================================================================
-- File Name    : skill.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-12-08 13:01:43
-- Description  :
-- Modify       :
--=======================================================================

if not Skill then
	Skill = {}
end

function Skill:Init( ... )

end

function Skill:CastSkill(szSkillName, tbLancher)
	local tbSkillCfg = self.tbCfg[szSkillName]
	if not tbSkillCfg then
		return
	end
	local func = tbSkillCfg.func
	local nRetCode, tbTargetList = func(self, tbLancher, tbSkillCfg)
	Event:FireEvent("CastSkill", szSkillName, tbLancher.dwId, tbTargetList)
	return nRetCode, tbSkillCfg.nCDFrame
end

function Skill:CastAroundPhysicAttack(tbLancher, tbCfg)
	if not tbLancher then
		assert(false)
		return 0
	end
	local tbTargetList = {}
	for nDirection = Def.DIR_START + 1, Def.DIR_END - 1 do
		local tbOffset = Def.tbMove[nDirection]
		local nLogicX, nLogicY = tbLancher:GetLogicPos()
		local nCheckLogicX, nCheckLogicY = nLogicX + tbOffset[1], nLogicY + tbOffset[2]
		local dwCharacterId = Maze:GetRandomUnit(nCheckLogicX, nCheckLogicY)
		if not dwCharacterId or dwCharacterId == 0 then
			return 0
		end
		local tbTarget = GameMgr:GetCharacterById(dwCharacterId)
		if not tbTarget then
			return 0
		end

		local nLancherAttack = tbLancher:GetProperty("Attack")
		local nTargetDefense = tbTarget:GetProperty("Defense")
		local nDamage = math.floor(nLancherAttack * (100 / (100 + nTargetDefense)))
		Event:FireEvent("CharacterPhyiscAttack", tbLancher.dwId, tbTarget.dwId, nDamage)
		tbTarget:ReceiveDamage(nDamage)

		tbTargetList[#tbTargetList + 1] = tbTarget
	end
	return 1, tbTargetList
end

function Skill:CastPhysicAttack(tbLancher, tbCfg)
	if not tbLancher then
		assert(false)
		return 0
	end
	local nDirection = tbLancher.nDirection	
	local tbOffset = Def.tbMove[nDirection]
	local nLogicX, nLogicY = tbLancher:GetLogicPos()
	local nCheckLogicX, nCheckLogicY = nLogicX + tbOffset[1], nLogicY + tbOffset[2]
	local dwCharacterId = Maze:GetRandomUnit(nCheckLogicX, nCheckLogicY)
	if not dwCharacterId or dwCharacterId == 0 then
		return 0
	end
	local tbTarget = GameMgr:GetCharacterById(dwCharacterId)
	if not tbTarget then
		return 0
	end

	local nLancherAttack = tbLancher:GetProperty("Attack")
	local nTargetDefense = tbTarget:GetProperty("Defense")
	local nDamage = math.floor(nLancherAttack * (100 / (100 + nTargetDefense)))
	Event:FireEvent("CharacterPhyiscAttack", tbLancher.dwId, tbTarget.dwId, nDamage)
	tbTarget:ReceiveDamage(nDamage)
	return 1, {tbTarget}
end

function Skill:CastLightAttack(tbLancher, tbCfg)
	if not tbLancher then
		assert(false)
		return 0
	end
	local pLancherSprite = tbLancher.pSprite
	local nX, nY = pLancherSprite:getPosition()
	local tbBulletProperty = {
		Damage       = tbLancher:GetProperty("Attack"),
		dwLancherId  = tbLancher.dwId,
		nMoveSpeed   = tbCfg.nBulletSpeed,
		szBulletType = "LightBall",
		szTargetType = "Enemy",
	}
	local nDirection = tbLancher.nDirection
	Bullet:AddBullet(nX , nY, nDirection, tbBulletProperty)
	return 1
end

function Skill:CastFireAttack(tbLancher, tbCfg)
	if not tbLancher then
		assert(false)
		return 0
	end
	local pLancherSprite = tbLancher.pSprite
	local nX, nY = pLancherSprite:getPosition()
	local tbBulletProperty = {
		Damage       = math.floor(tbLancher:GetProperty("Attack") * 1.5),
		dwLancherId  = tbLancher.dwId,
		nMoveSpeed   = tbCfg.nBulletSpeed,
		szBulletType = "Fire",
		szTargetType = "Enemy",
		bAOE = tbCfg.bAOE,
	}
	local nDirection = tbLancher.nDirection
	Bullet:AddBullet(nX , nY, nDirection, tbBulletProperty)
	return 1
end

function Skill:CastAOEFireAttack(tbLancher, tbCfg)
	if not tbLancher then
		assert(false)
		return 0
	end
	local pLancherSprite = tbLancher.pSprite
	local nX, nY = pLancherSprite:getPosition()
	local tbBulletProperty = {
		Damage       = math.floor(tbLancher:GetProperty("Attack") * 1),
		dwLancherId  = tbLancher.dwId,
		nMoveSpeed   = tbCfg.nBulletSpeed,
		szBulletType = "Fire",
		szTargetType = "Enemy",
		bAOE = tbCfg.bAOE,
	}
	for nDirection = Def.DIR_START + 1, Def.DIR_END - 1 do
		Bullet:AddBullet(nX , nY, nDirection, tbBulletProperty)
	end
	return 1
end

Skill.tbCfg = {
	["物理攻击"] = {nCDFrame = 10, func = Skill.CastPhysicAttack},
	["旋风斩"]	= {nCDFrame = 30, func = Skill.CastAroundPhysicAttack},
	["光魔法"]   = {nCDFrame = 30, nBulletSpeed = 8, func = Skill.CastLightAttack,},
	["火球术"]   = {nCDFrame = 30, nBulletSpeed = 4, bAOE = 1, func = Skill.CastFireAttack,},
	["十字火球术"]   = {nCDFrame = 60, nBulletSpeed = 4, bAOE = 1, func = Skill.CastAOEFireAttack,},
}
