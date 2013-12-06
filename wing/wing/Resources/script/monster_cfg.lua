--=======================================================================
-- File Name    : monster_cfg.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-12-05 10:27:30
-- Description  :
-- Modify       :
--=======================================================================

if OS_WIN32 then
	Monster.tbCfg = {
		[1] = {szImgFile = "image/monster/skeleton.png", },
		[2] = {szImgFile = "image/monster/witch.png", },
		[3] = {szImgFile = "image/monster/dragon.png", },
	}
else
	Monster.tbCfg = {
		[1] = {szImgFile = "skeleton.png", },
		[2] = {szImgFile = "witch.png", },
		[3] = {szImgFile = "dragon.png", },
	}
end