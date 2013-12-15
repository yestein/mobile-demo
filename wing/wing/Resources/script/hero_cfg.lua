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
-- 		Defense     = 5,
-- 		Magic       = 5,
-- 		Speed       = 1,
-- }

Hero.tbCfg = {
	[1]= {
		tbProperty = {MaxHP = 100, Attack = 40, Defense = 5, AttackRange = 5, Speed = 3},
		tbSkill = {"火球术"},
		szAIName = "HeroExplore",
	},
	[2]= {
		tbProperty = {MaxHP = 200, Attack = 20, Defense = 10, Speed = 4},
		tbSkill = {"物理攻击"},
		szAIName = "HeroExplore",
	},
	[999]= {
		tbProperty = {MaxHP = 10000, Attack = 15, Defense = 5, AttackRange = 5, Speed = 3},
		tbSkill = {"十字火球术"},
		szAIName = "HeroExplore",
	},
	[1000]= {
		tbProperty = {MaxHP = 10000, Attack = 15, Defense = 5, AttackRange = 5, Speed = 3},
		tbSkill = {"旋风斩"},
		szAIName = "HeroExplore",
	},
}

if OS_WIN32 then
	Hero.tbCfg[1].szImgFile = "image/hero/wizard.png"
	Hero.tbCfg[2].szImgFile = "image/hero/soldier.png"
	Hero.tbCfg[999].szImgFile = "image/hero/wizard.png"
	Hero.tbCfg[1000].szImgFile = "image/hero/soldier.png"
else
	Hero.tbCfg[1].szImgFile = "wizard.png"
	Hero.tbCfg[2].szImgFile = "soldier.png"
	Hero.tbCfg[999].szImgFile = "wizard.png"
	Hero.tbCfg[1000].szImgFile = "soldier.png"
end
