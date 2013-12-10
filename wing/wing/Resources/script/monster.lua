--=======================================================================
-- File Name    : monster.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-09-03 19:49:30
-- Description  :
-- Modify       :
--=======================================================================

require("monster_cfg")

local FRAME_WIDTH = 36
local FRAME_HEIGHT = 48
local INIT_DIRECTION = Def.DIR_DOWN

if not Monster.tbMonsterClass then
	Monster.tbMonsterClass = Lib:NewClass(Character)
end

local tbMonsterClass = Monster.tbMonsterClass

function Monster:Init()
	self.nOrginId = 101
	self.nNextId = self.nOrginId 
end

function Monster:Uninit()
	self.nOrginId = 101
	self.nNextId = self.nOrginId 
end

function Monster:GenerateId()
	local nRetId = self.nNextId
	self.nNextId = self.nNextId + 1
	return nRetId
end


function Monster:NewMonster(dwMonsterTemplateId, nStartX, nStartY, szAIName)
	local tbCfg = self.tbCfg[dwMonsterTemplateId]
	local szImgFile = tbCfg.szImgFile
	local TextureMonster = CCTextureCache:sharedTextureCache():addImage(szImgFile)
	local InitRect = CCRectMake(0, 0, Def.BLOCK_WIDTH, Def.BLOCK_HEIGHT)
	local MonsterFrame0 = CCSpriteFrame:createWithTexture(TextureMonster, InitRect)
	
	local tbProperty = tbCfg.tbProperty
	local tbNewMonster = Lib:NewClass(tbMonsterClass)
	local pMonster = CCSprite:createWithSpriteFrame(MonsterFrame0)
	pMonster.isPaused = true
	pMonster:setPosition(nStartX, nStartY)
	tbNewMonster.dwId = self:GenerateId()
    tbNewMonster:Init(pMonster, tbProperty, tbCfg.tbSkill, szAIName or tbCfg.szAIName)	
    GameMgr:AddCharacter(tbNewMonster.dwId, tbNewMonster)
	Event:FireEvent("MonsterAdd", tbNewMonster.dwId)
	return tbNewMonster, pMonster
end

function Monster:ClearAll()
	for dwId = self.nOrginId, self.nNextId - 1 do
		local tbMonster = GameMgr:GetCharacterById(dwId)
		if tbMonster then
			tbMonster:Die()
		end
	end
	self.nNextId = self.nOrginId 
end

function Monster:GetList()
	local tbRet = {}
	for dwId = self.nOrginId, self.nNextId - 1 do
		local tbMonster = GameMgr:GetCharacterById(dwId)
		if tbMonster then
			tbRet[dwId] = tbMonster
		end
	end
	return tbRet
end