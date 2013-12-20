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
		zName = "魔法师",
		tbProperty = {MaxHP = 80, Attack = 40, Defense = 50, AttackRange = 5, Speed = 1},
		tbSkill = {"光魔法"},
		szAIName = "HeroExplore",
	},
	[2]= {
		zName = "士兵A",
		tbProperty = {MaxHP = 120, Attack = 20, Defense = 100, Speed = 2},
		tbSkill = {"物理攻击"},
		szAIName = "HeroExplore",
	},
	[3]= {
		zName = "士兵B",
		tbProperty = {MaxHP = 120, Attack = 20, Defense = 100, Speed = 2},
		tbSkill = {"物理攻击"},
		szAIName = "HeroExplore",
	},
	[4]= {
		zName = "士兵C",
		tbProperty = {MaxHP = 120, Attack = 20, Defense = 100, Speed = 2},
		tbSkill = {"物理攻击"},
		szAIName = "HeroExplore",
	},
	[5]= {
		zName = "士兵D",
		tbProperty = {MaxHP = 120, Attack = 20, Defense = 100, Speed = 2},
		tbSkill = {"物理攻击"},
		szAIName = "HeroExplore",
	},
	[6]= {
		szName = "盗贼",
		tbProperty = {MaxHP = 100, Attack = 14, Defense = 80, Speed = 3},
		tbSkill = {"速击"},
		szAIName = "HeroExplore",
	},
	[999]= {
		zName = "测试用魔法师",
		tbProperty = {MaxHP = 10000, Attack = 15, Defense = 5, AttackRange = 5, Speed = 3},
		tbSkill = {"十字火球术"},
		szAIName = "HeroExplore",
	},
	[1000]= {
		zName = "测试用战士",
		tbProperty = {MaxHP = 10000, Attack = 15, Defense = 5, AttackRange = 5, Speed = 3},
		tbSkill = {"旋风斩"},
		szAIName = "HeroExplore",
	},
}

if OS_WIN32 then
	Hero.tbCfg[1].szImgFile = "image/hero/wizard.png"
	Hero.tbCfg[2].szImgFile = "image/hero/soldier_1.png"
	Hero.tbCfg[3].szImgFile = "image/hero/soldier_2.png"
	Hero.tbCfg[4].szImgFile = "image/hero/soldier_3.png"
	Hero.tbCfg[5].szImgFile = "image/hero/soldier_4.png"
	Hero.tbCfg[6].szImgFile = "image/hero/thief.png"
	Hero.tbCfg[999].szImgFile = "image/hero/wizard.png"
	Hero.tbCfg[1000].szImgFile = "image/hero/soldier_1.png"
else
	Hero.tbCfg[1].szImgFile = "wizard.png"
	Hero.tbCfg[2].szImgFile = "soldier_1.png"
	Hero.tbCfg[3].szImgFile = "soldier_2.png"
	Hero.tbCfg[4].szImgFile = "soldier_3.png"
	Hero.tbCfg[5].szImgFile = "soldier_4.png"
	Hero.tbCfg[6].szImgFile = "thief.png"
	Hero.tbCfg[999].szImgFile = "wizard.png"
	Hero.tbCfg[1000].szImgFile = "soldier_1.png"
end
