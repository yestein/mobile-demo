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
-- 		Defense     = 5,
-- 		Magic       = 5,
-- 		Speed       = 1,
-- }
require("maze")

Monster.tbCfg = {
	[1]= {
		tbProperty = {MaxHP = 40, Attack = 10, Defense = 50, AttackRange = 1},
		tbSkill = {"物理攻击"},
		szAIName = "NormalMove",
	},
	[2]= {
		tbProperty = {MaxHP = 20, Attack = 15, Defense = 10, AttackRange = 5, Speed = 2},
		tbSkill = {"光魔法"},
		szAIName = "NotMove"
	},
	[3]= {
		tbProperty = {MaxHP = 70, Attack = 20, Defense = 50, AttackRange = 5, Speed = 1},
		tbSkill = {"火球术"},
		szAIName = "NormalMove"
	},

	[999]= {
		tbProperty = {MaxHP = 10000, Attack = 15, Defense = 2, AttackRange = 5, Speed = 3},
		tbSkill = {"光魔法"},
		szAIName = "NormalMove"
	},
	[1000]= {
		tbProperty = {MaxHP = 10000, Attack = 10, Defense = 5, ViewRange = 1, AttackRange = 1},
		tbSkill = {"物理攻击"},
		szAIName = "NotMove"
	},
	[Maze.MAP_TARGET]= {
		tbProperty = {MaxHP = 10000, Attack = 0, Defense = 0, AttackRange = 0},
		tbSkill = {},
	},
}

if OS_WIN32 then
	Monster.tbCfg[1].szImgFile = "image/monster/skeleton.png"
	Monster.tbCfg[2].szImgFile = "image/monster/witch.png"
	Monster.tbCfg[3].szImgFile = "image/monster/dragon.png"
	Monster.tbCfg[999].szImgFile = "image/monster/witch.png"
	Monster.tbCfg[1000].szImgFile = "image/monster/skeleton.png"
	Monster.tbCfg[Maze.MAP_TARGET].szImgFile = "image/monster/target.png"
else
	Monster.tbCfg[1].szImgFile = "skeleton.png"
	Monster.tbCfg[2].szImgFile = "witch.png"
	Monster.tbCfg[3].szImgFile = "dragon.png"
	Monster.tbCfg[999].szImgFile = "witch.png"
	Monster.tbCfg[1000].szImgFile = "skeleton.png"
	Monster.tbCfg[Maze.MAP_TARGET].szImgFile = "target.png"
end
