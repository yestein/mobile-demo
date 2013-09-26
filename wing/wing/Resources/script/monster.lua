--=======================================================================
-- 文件名　：monster.lua
-- 创建者　：yulei(yulei1@kingsoft.com)
-- 创建时间：2013-09-03 19:49:30
-- 功能描述：
-- 修改列表：
--=======================================================================

local FRAME_WIDTH = 36
local FRAME_HEIGHT = 48
local INIT_DIRECTION = Def.DIR_DOWN
local TextureMonster = CCTextureCache:sharedTextureCache():addImage(Def.szMonsterFile)
local InitRect = CCRectMake(0, 0, Def.BLOCK_WIDTH, Def.BLOCK_HEIGHT)
local MonsterFrame0 = CCSpriteFrame:createWithTexture(TextureMonster, InitRect)

local Id = 100
local function Accumulator()
	Id = Id + 1
	return Id
end

if not Monster.tbMonsterClass then
	Monster.tbMonsterClass = Lib:NewClass(Character)
end

local tbMonsterClass = Monster.tbMonsterClass

function Monster:NewMonster(nStartX, nStartY, tbProperty)
	
	local tbNewMonster = Lib:NewClass(tbMonsterClass)
	local pMonster = CCSprite:createWithSpriteFrame(MonsterFrame0)
	pMonster.isPaused = true
	pMonster:setPosition(nStartX, nStartY)
	tbNewMonster.dwId = Accumulator()
    tbNewMonster:Init(pMonster, tbProperty, tbAI)	
    GameMgr:AddCharacter(tbNewMonster.dwId, tbNewMonster)
	
	return tbNewMonster, pMonster
end