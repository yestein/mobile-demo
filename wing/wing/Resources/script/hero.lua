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
	
	-- moving Hero at every frame
	local function tick()
	    if pSprite.isPaused then
	    	return
	    end
	end
	CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0, false)
end

function Hero:SetProperty(Key, Value)
	if self.tbProperty[k] then
		self.tbProperty[k] = v
		return 1
	end
	return 0
end

function Hero:Goto(nDir)
	
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

    self.pSprite:setPositionX(x)
end
    