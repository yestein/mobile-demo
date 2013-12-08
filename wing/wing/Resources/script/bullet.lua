--=======================================================================
-- File Name    : bullet.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-09-22 15:39:32
-- Description  :
-- Modify       :
--=======================================================================

local tbBulletClass = {}

local Id = 0
local function Accumulator()
	Id = Id + 1
	return Id
end

function Bullet:Init()
	self.tbBulletList = {}
	local bulletNode = CCSpriteBatchNode:create(Def.szBulletFile)
	bulletNode:setPosition(0, 0)
	local function tick()
		for dwBulletId, tbBullet in pairs(self.tbBulletList) do
			local nDirection = tbBullet.nDirection
			local tbProperty = tbBullet.tbProperty
			local nMoveSpeed = tbProperty.nMoveSpeed
			local tbPosOffset = Def.tbMove[nDirection]
			if tbPosOffset then
				local pSprite = tbBullet.pSprite
				local nX, nY = unpack(tbPosOffset)
				local x, y = pSprite:getPosition()
				local nNewX, nNewY = x + nX * nMoveSpeed, y + nY * nMoveSpeed
				pSprite:setPosition(nNewX, nNewY)

				local nRow, nCol = Lib:GetRowColByPos(nNewX, nNewY)
				if Maze:IsFree(nRow, nCol) == Maze.MAP_BLOCK  then
					tbBullet:Uninit()
					self.tbBulletList[dwBulletId] = nil
					return
				end
				local dwTargetId = Maze:GetUnit(nRow, nCol)
				if dwTargetId and dwTargetId > 0 then
					local tbCharacter = GameMgr:GetCharacterById(dwTargetId)
					if tbCharacter then
						if tbBullet:JudgeCollide(nRow, nCol, dwTargetId) == 1  then
							tbCharacter:BeAttacked(tbBullet)
							tbBullet:Uninit()
							self.tbBulletList[dwBulletId] = nil
						end
					end
				end		
			end			
	    end
	end
	CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0, false)
	self.bulletNode = bulletNode
	return bulletNode
end

function Bullet:AddBullet(nX, nY, nDirection, tbProperty)
	local tbBullet = Lib:NewClass(tbBulletClass)
	local dwId = Accumulator()
	tbBullet.dwId = dwId
	tbBullet:Init(nX, nY, tbProperty)
	tbBullet.nDirection = nDirection
	self.tbBulletList[dwId] = tbBullet
	return dwId
end

function Bullet.NotSameCamp(dwLancherId, dwTargetId)
	if Lib:IsHero(dwLancherId) == Lib:IsHero(dwTargetId) then
		return 0
	else
		return 1
	end
end

Bullet.tbJudgeCollide = {
	["Enemy"] = Bullet.NotSameCamp,
}

function tbBulletClass:Init(nX, nY, tbProperty)
	local pSprite = CCSprite:createWithTexture(Bullet.bulletNode:getTexture())
	pSprite:setPosition(nX, nY)
	Bullet.bulletNode:addChild(pSprite)
	self.pSprite = pSprite
	self.tbProperty = tbProperty
end

function tbBulletClass:JudgeCollide(nRow, nCol, dwTargetId)
	local func = Bullet.tbJudgeCollide[self.tbProperty.szTargetType]
	return func(self.tbProperty.dwLancherId, dwTargetId)
end

function tbBulletClass:CalcDamage(tbCharacter)
	local nCurHP = tbCharacter:GetProperty("CurHP")
	local nNewHP = nCurHP - self.tbProperty.Damage
	return nNewHP, self.tbProperty.Damage
end

function tbBulletClass:Uninit()
	Bullet.bulletNode:removeChild(self.pSprite, true)
end

