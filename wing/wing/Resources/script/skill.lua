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

function Skill:CastSkill(dwSkillId, tbLancher, tbTarget)
	local tbSkillCfg = self.tbCfg[dwSkillId]
	if not tbSkillCfg then
		return
	end
	local func = tbSkillCfg.func
	return func(self, tbLancher, tbTarget, tbSkillCfg)
end

function Skill:CastPhysicAttack(tbLancher, tbTarget, tbCfg)
	-- body
end

function Skill:CastFireAttack(tbLancher, tbTarget, tbCfg)
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
		szTargetType = "Enemy",
	}
	local nDirection = tbLancher.nDirection
	Bullet:AddBullet(nX , nY, nDirection, tbBulletProperty)
	tbLancher:Wait(30)
end

Skill.tbCfg = {
	[1] = {szName = "物理攻击", nCDFrame = 10, nBulletSpeed = 4, func = Skill.CastPhysicAttack},
	[2] = {szName = "火球攻击", nCDFrame = 30, nBulletSpeed = 8, func = Skill.CastFireAttack,}
}
