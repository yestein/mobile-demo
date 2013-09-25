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

local Id = 0
function Accumulator()
	Id = Id + 1
	return Id
end

if not Monster.tbMonsterClass then
	Monster.tbMonsterClass = Lib:NewClass(Character)
end

local tbMonsterClass = Monster.tbMonsterClass

function Monster:Init()
	self.tbMonster = {}
end

function Monster:NewMonster(nStartX, nStartY)
	
	local tbNewMonster = Lib:NewClass(tbMonsterClass)
	local pMonster = CCSprite:createWithSpriteFrame(MonsterFrame0)
	pMonster.isPaused = true
	pMonster:setPosition(nStartX, nStartY)
    tbNewMonster:Init(pMonster, tbProperty, tbAI)
	tbNewMonster.dwId = Accumulator()
	self.tbMonster[#self.tbMonster + 1] = tbNewMonster	
	
	
	return tbNewMonster, pMonster
end

function Monster:GetAllMonster()
	return self.tbMonster
end

function Monster:Start()
	for dwId, tbMonster in pairs(self.tbMonster) do
		tbMonster:Start()
	end
end

function Monster:Reset()
	for dwId, tbMonster in pairs(self.tbMonster) do
		tbMonster:Reset()
	end
end
