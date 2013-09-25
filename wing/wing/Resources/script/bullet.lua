--=======================================================================
-- 文件名　：bullet.lua
-- 创建者　：yestein (yestein86@gmail.com)
-- 创建时间：2013-09-22 15:39:32
-- 功能描述：
-- 修改列表：
--=======================================================================

local tbBulletClass = {}

local Id = 0
function Accumulator()
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
			if Maze:IsFree(nRow, nCol) == 1 then
				pSprite:setPosition(nNewX, nNewY)
			else
				tbBullet:Uninit()
				self.tbBulletList[dwBulletId] = nil
			end			
	    end
	end
	CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0, false)
	self.bulletNode = bulletNode
	return bulletNode
end

function Bullet:AddBullet(nX, nY, nDirection)
	local tbBullet = Lib:NewClass(tbBulletClass)
	local dwId = Accumulator()
	tbBullet.dwId = dwId
	tbBullet:Init(nX, nY)
	tbBullet.nDirection = nDirection
	self.tbBulletList[dwId] = tbBullet
end

function tbBulletClass:Init(nX, nY)
	local pSprite = CCSprite:createWithTexture(Bullet.bulletNode:getTexture())
	pSprite:setPosition(nX, nY)
	Bullet.bulletNode:addChild(pSprite)
	self.pSprite = pSprite
end

function tbBulletClass:Uninit()
	Bullet.bulletNode:removeChild(self.pSprite, true)
end

