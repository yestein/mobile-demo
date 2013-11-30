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
			local tbPosOffset = Def.tbMove[nDirection]
			if not tbPosOffset then
				return 0
			end
			local pSprite = tbBullet.pSprite
			local nX, nY = unpack(tbPosOffset)
			local x, y = pSprite:getPosition()
			local nNewX, nNewY = x + nX * 4, y + nY * 4
			local nRow, nCol = Lib:GetRowColByPos(nNewX, nNewY)
			local dwId = Maze:GetUnit(nRow, nCol)
			if Maze:IsFree(nRow, nCol) == 1 and dwId == 0 then
				pSprite:setPosition(nNewX, nNewY)
				return 0
			else
				if dwId > 0 then
					local tbCharacter = GameMgr:GetCharacterById(dwId)
					if Lib:IsHero(dwId) == 1 then
						tbCharacter:BeAttacked(tbBullet)
					else
						tbCharacter:BeAttacked(tbBullet)
					end
				end
				tbBullet:Uninit()
				self.tbBulletList[dwBulletId] = nil
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
end

function tbBulletClass:Init(nX, nY, tbProperty)
	local pSprite = CCSprite:createWithTexture(Bullet.bulletNode:getTexture())
	pSprite:setPosition(nX, nY)
	Bullet.bulletNode:addChild(pSprite)
	self.pSprite = pSprite
	self.tbProperty = tbProperty
end

function tbBulletClass:CalcDamage(tbCharacter)
	local nCurHP = tbCharacter:GetProperty("CurHP")
	local nNewHP = nCurHP - self.tbProperty.Damage
	cclog(nCurHP.."->"..nNewHP)
	return nNewHP
end

function tbBulletClass:Uninit()
	Bullet.bulletNode:removeChild(self.pSprite, true)
end

