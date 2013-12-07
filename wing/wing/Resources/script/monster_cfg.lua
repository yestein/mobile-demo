--=======================================================================
-- File Name    : monster_cfg.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-12-05 22:27:30
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

Monster.tbCfg = {
	[1]= {
		tbProperty = {MaxHP = 30, Attack = 10, Defence = 5, AttackRange = 1},
		szAIName = "NormalMove",
	},
	[2]= {
		tbProperty = {MaxHP = 20, Attack = 15, Defence = 2, AttackRange = 5, Speed = 5},
		szAIName = "NotMove"
	},
	[3]= {
		tbProperty = {MaxHP = 50, Attack = 10, Defence = 10, AttackRange = 3, Speed = 2},
		szAIName = "NotMove"
	},

	[999]= {
		tbProperty = {MaxHP = 10000, Attack = 15, Defence = 2, AttackRange = 5, Speed = 5},
		szAIName = "NotMove"
	},
}

if OS_WIN32 then
	Monster.tbCfg[1].szImgFile = "image/monster/skeleton.png"
	Monster.tbCfg[2].szImgFile = "image/monster/witch.png"
	Monster.tbCfg[3].szImgFile = "image/monster/dragon.png"
	Monster.tbCfg[999].szImgFile = "image/monster/witch.png"
else
	Monster.tbCfg[1].szImgFile = "skeleton.png"
	Monster.tbCfg[2].szImgFile = "witch.png"
	Monster.tbCfg[3].szImgFile = "dragon.png"
	Monster.tbCfg[999].szImgFile = "witch.png"
end
