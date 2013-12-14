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
	return nRetCode
end

function Skill:CastPhysicAttack(tbLancher, tbCfg)
	if not tbLancher then
		assert(false)
		return 0
	end
	local nDirection = tbLancher.nDirection	
	local tbOffset = Def.tbMove[nDirection]
	local nCheckRow, nCheckCol = tbLancher.tbLogicPos.nRow + tbOffset[2], tbLancher.tbLogicPos.nCol + tbOffset[1]
	local dwCharacterId = Maze:GetUnit(nCheckRow, nCheckCol)
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
	return 1, tbTarget
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
	}
	local nDirection = tbLancher.nDirection
	Bullet:AddBullet(nX , nY, nDirection, tbBulletProperty)
	return 1
end

Skill.tbCfg = {
	["物理攻击"] = {nCDFrame = 10, nBulletSpeed = 4, func = Skill.CastPhysicAttack},
	["光魔法"]   = {nCDFrame = 30, nBulletSpeed = 8, func = Skill.CastLightAttack,},
	["火魔法"]   = {nCDFrame = 30, nBulletSpeed = 2, func = Skill.CastFireAttack,},
}
