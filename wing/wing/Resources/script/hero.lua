--===================================================
-- File Name    : hero.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-08-07 13:09:07
-- Description  :
-- Modify       :
--===================================================

require("hero_cfg")
local frameWidth = 36
local frameHeight = 48

if not Hero.tbHeroClass then
	Hero.tbHeroClass = Lib:NewClass(Character)
end

local tbHeroClass = Hero.tbHeroClass

function Hero:Init()
	self.nOrginId = 1
	self.nNextId = self.nOrginId 
end

function Hero:Uninit()
	self.nOrginId = 1
	self.nNextId = self.nOrginId 
end

function Hero:GenerateId()
	local nRetId = self.nNextId
	self.nNextId = self.nNextId + 1
	return nRetId
end

function Hero:NewHero(dwHeroTemplateId, nStartX, nStartY)
	-- create hero animate
	local tbCfg = self.tbCfg[dwHeroTemplateId]
	local textureHero = CCTextureCache:sharedTextureCache():addImage(tbCfg.szImgFile)
	local rect = CCRectMake(0, frameHeight, frameWidth, frameHeight)
	local frame0 = CCSpriteFrame:createWithTexture(textureHero, rect)
	local tbNewHero = Lib:NewClass(tbHeroClass)
    local pHero = CCSprite:createWithSpriteFrame(frame0)
    pHero:setPosition(nStartX, nStartY)
    pHero.isPaused = true
    tbNewHero.dwId = self:GenerateId()
    local tbProperty = tbCfg.tbProperty
	tbNewHero:Init(pHero, dwHeroTemplateId, tbProperty, tbCfg.tbSkill, tbCfg.szAIName)
	GameMgr:AddCharacter(tbNewHero.dwId, tbNewHero)
	Event:FireEvent("HeroAdd", tbNewHero.dwId)
	return tbNewHero, pHero
end

function Hero:ClearAll()
	for dwId = self.nOrginId, self.nNextId - 1 do
		local tbHero = GameMgr:GetCharacterById(dwId)
		if tbHero then
			tbHero:Die()
		end
	end
	self.nNextId = self.nOrginId 
end

function Hero:GetList()
	local tbRet = {}
	for dwId = self.nOrginId, self.nNextId - 1 do
		local tbHero = GameMgr:GetCharacterById(dwId)
		if tbHero then
			tbRet[dwId] = tbHero
		end
	end
	return tbRet
end

function tbHeroClass:Finish()
	self.bFinish = 1
end

function tbHeroClass:IsFinish()
	return self.bFinish
end

function tbHeroClass:TryGoto(nLogicX, nLogicY)
	if self:IsExplored(nLogicX, nLogicY) == 1 then
		return 0
	end
	if Maze:CanMove(nLogicX, nLogicY) ~= 1 then
		return 0
	end
	
    return 1
end

function tbHeroClass:RecordPos(nX, nY)
	if not self.tbRecordPos[nX] then
		self.tbRecordPos[nX] = {}
	end
 
	self.tbRecordPos[nX][nY] = 1
end

function tbHeroClass:IsExplored(nX, nY)
	if self.tbRecordPos[nX] then
		return self.tbRecordPos[nX][nY]
	end
	return nil
end

function tbHeroClass:PushPos(nDir)
	if not nDir then
		return 0
	end
	local nOppDir = Lib:GetOppositeDirection(nDir)
	table.insert(self.tbStack, nOppDir)
	return 1
end

function tbHeroClass:PopPos()
	if #self.tbStack == 0 then
		return
	end
	local nDir = self.tbStack[#self.tbStack]
	self.tbStack[#self.tbStack] = nil
	return nDir
end

function tbHeroClass:IsExploreViewRange(nX, nY)
	if self.tbExplore and self.tbExplore[nX] and self.tbExplore[nX][nY] then
		return 1
	end
end

function tbHeroClass:ExploreMaze()
	if not self.tbExplore then
		self.tbExplore = {}
	end
	local nFindRange = self.tbProperty.ViewRange
	local nLogicX, nLogicY = self:GetLogicPos()
	for x = nLogicX - nFindRange, nLogicX + nFindRange do
		if not self.tbExplore[x] then
			self.tbExplore[x] = {}
		end
		for y = nLogicY - nFindRange, nLogicY + nFindRange do
			if not self.tbExplore[x][y] then
				if math.floor(Lib:GetDistance(x, y, nLogicX, nLogicY)) <= nFindRange then
					self.tbExplore[x][y] = 1
					if Maze:IsFree(x, y) ~= 1 then
						local pSprite = Maze:GetBlock(x, y)
						if pSprite then
							pSprite:setVisible(true)
						end
					end
					local tbUnit = Maze:GetUnit(x, y)
					for dwMonsterId, _ in pairs(tbUnit) do
						local tbMonster = GameMgr:GetCharacterById(dwMonsterId)
						if tbMonster and tbMonster.pSprite then
							tbMonster.pSprite:setVisible(true)
						end
					end
				end
			end
		end
	end
end