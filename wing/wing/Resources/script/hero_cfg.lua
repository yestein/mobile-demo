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
		tbProperty = {MaxHP = 100, Attack = 15, Defence = 5, AttackRange = 5, Speed = 3},
	},
	[2]= {
		tbProperty = {MaxHP = 200, Attack = 10, Defence = 10, Speed = 2},
	},
}

if OS_WIN32 then
	Hero.tbCfg[1].szImgFile = "image/hero/wizzard.png"
	Hero.tbCfg[2].szImgFile = "image/hero/soldier.png"
else
	Hero.tbCfg[1].szImgFile = "wizzard.png"
	Hero.tbCfg[2].szImgFile = "soldier.png"
end
