--=======================================================================
-- File Name    : main_scene.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-12-15 12:17:43
-- Description  :
-- Modify       :
--=======================================================================

local MainScene = SceneMgr:GetClass("MainScene", 1)

function MainScene:Create()
	local sceneMain = self:GetCCObj()
	if not sceneMain then
		return
	end

	local tbVisibleSize = CCDirector:sharedDirector():getVisibleSize()
	local tbOrigin = CCDirector:sharedDirector():getVisibleOrigin()
    local nOffsetX = tbVisibleSize.width / 2
    local nOffsetY = tbVisibleSize.height / 2

    local layerBG = CCLayer:create()
    local spriteBG = CCSprite:create(Def.szMainBGImg)
    local tbSize = spriteBG:getTextureRect().size
    local scale = tbVisibleSize.width / tbSize.width
    spriteBG:setPosition(tbOrigin.x, tbOrigin.y)
    spriteBG:setScale(scale)
    layerBG:setPosition(nOffsetX, nOffsetY)
    layerBG:addChild(spriteBG)

	return layerBG
end