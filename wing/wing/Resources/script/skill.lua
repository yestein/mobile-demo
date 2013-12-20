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

function Skill:CastPhysicAttack(tbLancher, tbCfg)
	if not tbLancher then
		assert(false)
		return 0
	end
	local tbTargetList = {}
	local nEffectRate = tbCfg.nEffectRate
	local tbDirection = tbCfg.tbParam.tbDirection
	for _, nSkillDirection in pairs(tbDirection) do
		local nDirection = nSkillDirection
		if nDirection == -1 then
			nDirection = tbLancher.nDirection
		end
		local tbOffset = Def.tbMove[nDirection]
		local nLogicX, nLogicY = tbLancher:GetLogicPos()
		local nCheckLogicX, nCheckLogicY = nLogicX + tbOffset[1], nLogicY + tbOffset[2]
		local tbCharacterId = Maze:GetUnit(nCheckLogicX, nCheckLogicY)
		for dwCharacterId, _ in pairs(tbCharacterId) do
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
			local nDamage = math.floor(nLancherAttack * nEffectRate * (100 / (100 + nTargetDefense)))
			Event:FireEvent("CharacterPhyiscAttack", tbLancher.dwId, tbTarget.dwId, nDamage)
			tbTarget:ReceiveDamage(nDamage)

			tbTargetList[#tbTargetList + 1] = tbTarget
			if tbCfg.tbParam.bAOE ~= 1 then
				break
			end
		end
	end
	return 1, tbTargetList
end

function Skill:CastBullet(tbLancher, tbCfg)
	if not tbLancher then
		assert(false)
		return 0
	end
	local nEffectRate = tbCfg.nEffectRate
	local pLancherSprite = tbLancher.pSprite
	local nX, nY = pLancherSprite:getPosition()
	local tbBulletProperty = {
		Damage       = math.floor(tbLancher:GetProperty("Attack") * nEffectRate),
		dwLancherId  = tbLancher.dwId,
		nMoveSpeed   = tbCfg.tbParam.nBulletSpeed,
		szBulletType = tbCfg.tbParam.szBulletType,
		szTargetType = tbCfg.tbParam.szTargetType,
		bAOE         = tbCfg.tbParam.bAOE,
	}
	local tbDirection = tbCfg.tbParam.tbDirection
	for _, nDirection in pairs(tbDirection) do
		if nDirection == -1 then
			Bullet:AddBullet(nX , nY, tbLancher.nDirection, tbBulletProperty)
		else
			Bullet:AddBullet(nX , nY, nDirection, tbBulletProperty)
		end
	end
	return 1
end

Skill.tbCfg = {

	["物理攻击"] = {
		nCDFrame = 60, nEffectRate = 1, func = Skill.CastPhysicAttack, 
		tbParam = {
			bAOE = 0,
			tbDirection = {-1},
		},
	},

	["旋风斩"]	= {
		nCDFrame = 90, nEffectRate = 0.8, func = Skill.CastPhysicAttack, 
		tbParam = {
			bAOE = 1,
			tbDirection = {Def.DIR_DOWN, Def.DIR_RIGHT, Def.DIR_UP, Def.DIR_LEFT,},
		},
	},

	["速击"] = {
		nCDFrame = 30, nEffectRate = 1, func = Skill.CastPhysicAttack, 
		tbParam = {
			bAOE = 0,
			tbDirection = {-1},
		},
	},


	["光魔法"]   = {
		nCDFrame = 90, nEffectRate = 1, func = Skill.CastBullet,
		tbParam = {
			szBulletType = "LightBall", szTargetType = "Enemy", nBulletSpeed = 8, bAOE = 0, 
			tbDirection = {-1},
		},
	},

	["火球术"]   = {
		nCDFrame = 120, nEffectRate = 1.5, bAOE = 1, func = Skill.CastBullet,
		tbParam = {
			szBulletType = "Fire", szTargetType = "Enemy", nBulletSpeed = 4,  bAOE = 1, 
			tbDirection = {-1},
		},
	},

	["十字火球术"]   = {
		nCDFrame = 120, nEffectRate = 1, bAOE = 1, func = Skill.CastBullet,
		tbParam = {
			szBulletType = "Fire", szTargetType = "Enemy", nBulletSpeed = 4,  bAOE = 1, 
			tbDirection = {Def.DIR_DOWN, Def.DIR_RIGHT, Def.DIR_UP, Def.DIR_LEFT,},
		},
	},
}