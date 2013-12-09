--=======================================================================
-- File Name    : hero_cfg.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-12-05 23:21:12
-- Description  :
-- Modify       :
--=======================================================================

-- self.tbProperty = {
-- 		ViewRange   = 5,
-- 		CurHP       = 0,
-- 		MaxHP       = 20,
-- 		CurMP       = 0,
-- 		MaxMP       = 0,
-- 		Attack      = 5,
-- 		AttackRange = 1,
-- 		Defence     = 5,
-- 		Magic       = 5,
-- 		Speed       = 1,
-- }

Hero.tbCfg = {
	[1]= {
		tbProperty = {MaxHP = 100, Attack = 15, Defence = 5, AttackRange = 5, Speed = 15},
		tbSkill = {"光魔法"},
	},
	[2]= {
		tbProperty = {MaxHP = 200, Attack = 10, Defence = 10, Speed = 10},
		tbSkill = {"光魔法"},
	},
	[999]= {
		tbProperty = {MaxHP = 10000, Attack = 15, Defence = 5, AttackRange = 5, Speed = 15},
		tbSkill = {"光魔法", "火魔法"},
	},
}

if OS_WIN32 then
	Hero.tbCfg[1].szImgFile = "image/hero/wizard.png"
	Hero.tbCfg[2].szImgFile = "image/hero/soldier.png"
	Hero.tbCfg[999].szImgFile = "image/hero/wizard.png"
else
	Hero.tbCfg[1].szImgFile = "wizard.png"
	Hero.tbCfg[2].szImgFile = "soldier.png"
	Hero.tbCfg[999].szImgFile = "wizard.png"
end
