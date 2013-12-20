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
	[4]= {
		tbProperty = {MaxHP = 40, Attack = 10, Defense = 50, AttackRange = 1},
		tbSkill = {"物理攻击"},
		szAIName = "NormalMove",
	},
	[5]= {
		tbProperty = {MaxHP = 20, Attack = 15, Defense = 10, AttackRange = 5, Speed = 2},
		tbSkill = {"光魔法"},
		szAIName = "NotMove"
	},
	[6]= {
		tbProperty = {MaxHP = 70, Attack = 20, Defense = 50, AttackRange = 5, Speed = 1},
		tbSkill = {"火球术"},
		szAIName = "NormalMove"
	},
	[7]= {
		tbProperty = {MaxHP = 40, Attack = 10, Defense = 50, AttackRange = 1},
		tbSkill = {"物理攻击"},
		szAIName = "NormalMove",
	},
	[8]= {
		tbProperty = {MaxHP = 20, Attack = 15, Defense = 10, AttackRange = 5, Speed = 2},
		tbSkill = {"光魔法"},
		szAIName = "NotMove"
	},
	[9]= {
		tbProperty = {MaxHP = 70, Attack = 20, Defense = 50, AttackRange = 5, Speed = 1},
		tbSkill = {"火球术"},
		szAIName = "NormalMove"
	},
	[10]= {
		tbProperty = {MaxHP = 40, Attack = 10, Defense = 50, AttackRange = 1},
		tbSkill = {"物理攻击"},
		szAIName = "NormalMove",
	},
	[11]= {
		tbProperty = {MaxHP = 20, Attack = 15, Defense = 10, AttackRange = 5, Speed = 2},
		tbSkill = {"光魔法"},
		szAIName = "NotMove"
	},
	[12]= {
		tbProperty = {MaxHP = 70, Attack = 20, Defense = 50, AttackRange = 5, Speed = 1},
		tbSkill = {"火球术"},
		szAIName = "NormalMove"
	},
	[13]= {
		tbProperty = {MaxHP = 40, Attack = 10, Defense = 50, AttackRange = 1},
		tbSkill = {"物理攻击"},
		szAIName = "NormalMove",
	},
	[14]= {
		tbProperty = {MaxHP = 20, Attack = 15, Defense = 10, AttackRange = 5, Speed = 2},
		tbSkill = {"光魔法"},
		szAIName = "NotMove"
	},
	[15]= {
		tbProperty = {MaxHP = 70, Attack = 20, Defense = 50, AttackRange = 5, Speed = 1},
		tbSkill = {"火球术"},
		szAIName = "NormalMove"
	},
	[16]= {
		tbProperty = {MaxHP = 40, Attack = 10, Defense = 50, AttackRange = 1},
		tbSkill = {"物理攻击"},
		szAIName = "NormalMove",
	},
	[17]= {
		tbProperty = {MaxHP = 20, Attack = 15, Defense = 10, AttackRange = 5, Speed = 2},
		tbSkill = {"光魔法"},
		szAIName = "NotMove"
	},
	[18]= {
		tbProperty = {MaxHP = 70, Attack = 20, Defense = 50, AttackRange = 5, Speed = 1},
		tbSkill = {"火球术"},
		szAIName = "NormalMove"
	},
	[19]= {
		tbProperty = {MaxHP = 70, Attack = 20, Defense = 50, AttackRange = 5, Speed = 1},
		tbSkill = {"火球术"},
		szAIName = "NormalMove"
	},
	[20]= {
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
	Monster.tbCfg[4].szImgFile = "image/monster/dark_knight_1.png"
	Monster.tbCfg[5].szImgFile = "image/monster/dark_knight_2.png"
	Monster.tbCfg[6].szImgFile = "image/monster/devil_1.png"
	Monster.tbCfg[7].szImgFile = "image/monster/devil_2.png"
	Monster.tbCfg[8].szImgFile = "image/monster/devil_3.png"
	Monster.tbCfg[9].szImgFile = "image/monster/lion_1.png"
	Monster.tbCfg[10].szImgFile = "image/monster/lion_2.png"
	Monster.tbCfg[11].szImgFile = "image/monster/evil_eye.png"
	Monster.tbCfg[12].szImgFile = "image/monster/ox_warrior.png"
	Monster.tbCfg[13].szImgFile = "image/monster/mouse.png"
	Monster.tbCfg[14].szImgFile = "image/monster/slime_raw.png"
	Monster.tbCfg[15].szImgFile = "image/monster/slime_cure.png"
	Monster.tbCfg[16].szImgFile = "image/monster/tiger.png"
	Monster.tbCfg[17].szImgFile = "image/monster/snow_man.png"
	Monster.tbCfg[18].szImgFile = "image/monster/zombie.png"
	Monster.tbCfg[19].szImgFile = "image/monster/rabbit.png"
	Monster.tbCfg[20].szImgFile = "image/monster/frog.png"
	Monster.tbCfg[999].szImgFile = "image/monster/witch.png"
	Monster.tbCfg[1000].szImgFile = "image/monster/skeleton.png"
	Monster.tbCfg[Maze.MAP_TARGET].szImgFile = "image/monster/target.png"
else
	Monster.tbCfg[1].szImgFile = "skeleton.png"
	Monster.tbCfg[2].szImgFile = "witch.png"
	Monster.tbCfg[3].szImgFile = "dragon.png"
	Monster.tbCfg[4].szImgFile = "dark_knight_1.png"
	Monster.tbCfg[5].szImgFile = "dark_knight_2.png"
	Monster.tbCfg[6].szImgFile = "devil_1.png"
	Monster.tbCfg[7].szImgFile = "devil_2.png"
	Monster.tbCfg[8].szImgFile = "devil_3.png"
	Monster.tbCfg[9].szImgFile = "lion_1.png"
	Monster.tbCfg[10].szImgFile = "lion_2.png"
	Monster.tbCfg[11].szImgFile = "evil_eye.png"
	Monster.tbCfg[12].szImgFile = "ox_warrior.png"
	Monster.tbCfg[13].szImgFile = "mouse.png"
	Monster.tbCfg[14].szImgFile = "slime_raw.png"
	Monster.tbCfg[15].szImgFile = "slime_cure.png"
	Monster.tbCfg[16].szImgFile = "tiger.png"
	Monster.tbCfg[17].szImgFile = "snow_man.png"
	Monster.tbCfg[18].szImgFile = "zombie.png"
	Monster.tbCfg[19].szImgFile = "rabbit.png"
	Monster.tbCfg[20].szImgFile = "frog.png"
	Monster.tbCfg[999].szImgFile = "witch.png"
	Monster.tbCfg[1000].szImgFile = "skeleton.png"
	Monster.tbCfg[Maze.MAP_TARGET].szImgFile = "target.png"
end
