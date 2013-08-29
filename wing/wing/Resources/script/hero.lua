--===================================================
-- File Name    : hero.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-08-07 13:09:07
-- Description  :
-- Modify       :
--===================================================

Hero.DIR_UP = 1
Hero.DIR_DOWN = 2
Hero.DIR_LEFT = 3
Hero.DIR_RIGHT = 4

Hero.tbMove = {
	[Hero.DIR_UP] = {0, 1},
	[Hero.DIR_DOWN] = {0, -1},
	[Hero.DIR_LEFT] = {-1, 0},
	[Hero.DIR_RIGHT] = {1, 0},
}

function Hero:Init(pSprite, tbProperty)
	self.pSprite = pSprite
	self.tbProperty = {
		CurHP = 1,
		MaxHP = 1,
		CurMP = 1,
		MaxMP = 1,
		Attack = 1,
		Defence = 1,
		Magic = 1,
		Speed = 1,
	}
	for k, v in pairs(tbProperty) do
		self:SetProperty(k, v)
	end
end

function Hero:SetProperty(Key, Value)
	if self.tbProperty[k] then
		self.tbProperty[k] = v
		return 1
	end
	return 0
end

function Hero:Move(nDir)
	local tbPosOffset = self.tbMove[nDir]
	if not tbPosOffset then
		return
	end
	local nX, nY = unpack(tbPosOffset)
	local x, y = self.pSprite:getPosition()
    if x > tbOrigin.x + tbVisibleSize.width then
        x = tbOrigin.x
    else
        x = x + 1
    end

    spriteDog:setPositionX(x)
end