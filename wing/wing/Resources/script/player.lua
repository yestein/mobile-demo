--===================================================
-- File Name    : player.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-08-07 13:08:52
-- Description  :
-- Modify       :
--===================================================

Player.ORGINAL_DIG_POINT = 25
Player.ORGINAL_GOLD      = 1000
Player.ORGINAL_MAGIC     = 1000

Player.tbResourceMax = {
	[1]  = {DigPoint = 25, Gold = 3000, Magic = 3000,},
	[2]  = {DigPoint = 35, Gold = 6000, Magic = 6000,},
	[3]  = {DigPoint = 45, Gold = 9000, Magic = 9000,},
	[4]  = {DigPoint = 55, Gold = 15000, Magic = 15000,},
	[5]  = {DigPoint = 70, Gold = 20000, Magic = 20000,},
	[6]  = {DigPoint = 90, Gold = 25000, Magic = 25000,},
	[7]  = {DigPoint = 115, Gold = 40000, Magic = 40000,},
	[8]  = {DigPoint = 130, Gold = 50000, Magic = 50000,},
	[9]  = {DigPoint = 160, Gold = 60000, Magic = 60000,},
	[10] = {DigPoint = 200, Gold = 80000, Magic = 80000,},
}

function Player:Init()
	self.nLevel     = 1
	self.tbResource = {DigPoint = 0, Gold = 0, Magic = 0,}
	self.tbMonster  = {}
	self.tbHero     = {}

	self:SetLevel(1)
	self:SetResouce("DigPoint", self.ORGINAL_DIG_POINT) 
	self:SetResouce("Gold", self.ORGINAL_GOLD)
	self:SetResouce("Magic", self.ORGINAL_MAGIC)
	self:SetOwnMonsterCount(3, 1)
	self:SetOwnHeroCount(1, 1)

	--self:RegistEvent()
end

function Player:Entry(tbData)
	self:SetLevel(tbData.nLevel)
	self:SetResouce("DigPoint", tbData.tbResource.DigPoint) 
	self:SetResouce("Gold", tbData.tbResource.Gold) 
	self:SetResouce("Magic", tbData.tbResource.Magic) 
	for dwMonsterTemplateId, nCount in pairs(tbData.tbMonster) do
		self:SetOwnMonsterCount(dwMonsterTemplateId, nCount)
	end
	for dwHeroTemplateId, nCount in pairs(tbData.tbHero) do
		self:SetOwnHeroCount(dwHeroTemplateId, nCount)
	end
end

function Player:Save( ... )
	cclog("Save Player ...")
    local szPath = CCFileUtils:sharedFileUtils():getWritablePath()
	local file = assert(io.open(szPath.."saveplayer.lua", "w"))

	file:write(string.format("Player:Entry{\nself.nLevel = %d,\n", self.nLevel))
	file:write("self.tbResource = {")
	for szResourceName, nCount in pairs(self.tbResource) do
		file:write(string.format("\"%s\"] = %d,\n", szResourceName, nCount))
	end
	file:write("},\n")
	file:write("self.tbMonster = {")
	for dwMonsterTemplateId, nCount in pairs(self.tbMonster) do
		file:write(string.format("[%d] = %d,\n", dwMonsterTemplateId, nCount))
	end
	file:write("},\n")
	file:write("self.tbHero = {")
	for dwHeroTemplateId, nCount in pairs(self.tbHero) do
		file:write(string.format("[%d] = %d,\n", dwHeroTemplateId, nCount))
	end
	file:write("},\n}")
	file:close()
	Event:FireEvent("SavePlayer")
end

function Player:Load( ... )
	cclog("Load Player ...")
	local szPath = CCFileUtils:sharedFileUtils():getWritablePath()
	local file = io.open(szPath.."saveplayer.lua", "r")
	if not file then
		return
	end
	local t = dofile(szPath.."saveplayer.lua")
	Event:FireEvent("LoadPlayer")
end

function Player:GetLevel()
	return self.nLevel
end

function Player:SetLevel(nLevel)
	local nOldLevel = self.nLevel
	self.nLevel = nLevel
	Event:FireEvent("PlayerLevelChange", nLevel, nOldLevel)
end

function Player:GetResouce(szResourceName)
	return self.tbResource[szResourceName]
end

function Player:GetCurResouceMax(szResourceName)
	local nLevel = self.nLevel
	local tbMax = self.tbResourceMax[nLevel]
	if not tbMax then
		tbMax = self.tbResourceMax[#self.tbResourceMax]
	end

	return tbMax[szResourceName]
end

function Player:SetResouce(szResourceName, nCount)
	local nMax = self:GetCurResouceMax(szResourceName)
	local bMax = nil
	if nCount > nMax then
		nCount = nMax
		bMax = 1
	elseif nCount < 0 then
		nCount = 0
	end
	self.tbResource[szResourceName] = nCount
	Event:FireEvent("SetResouce", szResourceName, nCount, bMax)
end

function Player:GetOwnMonsterCount(dwMonsterTemplateId)
	return self.tbMonster[dwMonsterTemplateId]
end

function Player:SetOwnMonsterCount(dwMonsterTemplateId, nCount)
	self.tbMonster[dwMonsterTemplateId] = nCount
	Event:FireEvent("SetOwnMonsterCount", dwMonsterTemplateId, nCount)
end

function Player:GetOwnHeroCount(dwHeroTemplateId)
	return self.tbHero[dwHeroTemplateId]
end

function Player:SetOwnHeroCount(dwHeroTemplateId, nCount)
	self.tbHero[dwHeroTemplateId] = nCount
	Event:FireEvent("SetOwnHeroCount", dwHeroTemplateId, nCount)
end

function Player:RegistEvent()
	if not self.nRegDig then
		self.nRegDig = Event:RegistEvent("Dig", self.OnDig, self)
	end

	if not self.nRegUnDoDig then
		self.nRegUnDoDig = Event:RegistEvent("UnDoDig", self.OnUnDoDig, self)
	end

	if not self.nRegMazeReset then
		self.nRegMazeReset = Event:RegistEvent("ResetMaze", self.OnResetMaze, self)
	end
end

function Player:UnRegistEvent()
	if self.nRegDig then
		Event:UnRegistEvent("Dig", self.nRegDig)
		self.nRegDig = nil
	end

	if self.nRegUnDoDig then
		Event:UnRegistEvent("UnDoDig", self.nRegUnDoDig)
		self.nRegUnDoDig = nil
	end

	if self.nRegMazeReset then
		Event:UnRegistEvent("ResetMaze", self.nRegMazeReset)
		self.nRegMazeReset = nil
	end
end

function Player:OnDig(nRow, nCol, bReDo)
	local nDigPoint = self:GetResouce("DigPoint")
	nDigPoint = nDigPoint - 1
	self:SetResouce("DigPoint", nDigPoint)
	return
end

function Player:UnDoDig(nRow, nCol, bReDo)
	local nDigPoint = self:GetResouce("DigPoint")
	nDigPoint = nDigPoint + 1
	self:SetResouce("DigPoint", nDigPoint)
	return
end

function Player:OnResetMaze()
	local nMaxDigPoint = self:GetCurResouceMax("DigPoint")
	self:SetResouce("DigPoint", nMaxDigPoint)
	return
end