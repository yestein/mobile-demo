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

function Skill:CastSkill(szSkillName, tbLancher, tbTarget)
	local tbSkillCfg = self.tbCfg[szSkillName]
	if not tbSkillCfg then
		return
	end
	local func = tbSkillCfg.func
	local nRetCode = func(self, tbLancher, tbTarget, tbSkillCfg)
	Event:FireEvent("CastSkill", szSkillName, tbLancher.dwId, tbTarget and tbTarget.dwId)
	return nRetCode
end

function Skill:CastPhysicAttack(tbLancher, tbTarget, tbCfg)
	-- body
end

function Skill:CastLightAttack(tbLancher, tbTarget, tbCfg)
	if not tbLancher then
		assert(false)
		return
	end
	local pLancherSprite = tbLancher.pSprite
	local nX, nY = pLancherSprite:getPosition()
	local tbBulletProperty = {
		Damage = tbLancher:GetProperty("Attack"),
		dwLancherId = tbLancher.dwId,
		nMoveSpeed = tbCfg.nBulletSpeed,
		szBulletType = "LightBall",
		szTargetType = "Enemy",
	}
	local nDirection = tbLancher.nDirection
	Bullet:AddBullet(nX , nY, nDirection, tbBulletProperty)
	tbLancher:Wait(30)
end

function Skill:CastFireAttack(tbLancher, tbTarget, tbCfg)
	if not tbLancher then
		assert(false)
		return
	end
	local pLancherSprite = tbLancher.pSprite
	local nX, nY = pLancherSprite:getPosition()
	local tbBulletProperty = {
		Damage = math.floor(tbLancher:GetProperty("Attack") * 1.5),
		dwLancherId = tbLancher.dwId,
		nMoveSpeed = tbCfg.nBulletSpeed,
		szBulletType = "Fire",
		szTargetType = "Enemy",
	}
	local nDirection = tbLancher.nDirection
	Bullet:AddBullet(nX , nY, nDirection, tbBulletProperty)
	tbLancher:Wait(30)
end

Skill.tbCfg = {
	["物理攻击"] = {nCDFrame = 10, nBulletSpeed = 4, func = Skill.CastPhysicAttack},
	["光魔法"] = {nCDFrame = 30, nBulletSpeed = 8, func = Skill.CastLightAttack,},
	["火魔法"] = {nCDFrame = 30, nBulletSpeed = 2, func = Skill.CastFireAttack,},
}
