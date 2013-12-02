--=======================================================================
-- File Name    : title.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-11-28 20:57:43
-- Description  :
-- Modify       :
--=======================================================================


function GameMgr:InitTitle()
	self.tbTitle = {}
	local sceneGame = SceneMgr:GetSceneObj("GameScene")
	if not sceneGame then
		return
	end
	local frameWidth = 36
	local frameHeight = 48
	local textureHero = CCTextureCache:sharedTextureCache():addImage(Def.szHeroFile)
	local rect = CCRectMake(0, frameHeight, frameWidth, frameHeight)
	local frame0 = CCSpriteFrame:createWithTexture(textureHero, rect)

	local tbVisibleSize = CCDirector:sharedDirector():getVisibleSize()
	local layerTitle = CCLayer:create()
    layerTitle:setPosition(0, 0)
    local cclf = CCLabelTTF:create("当前模式", "Microsoft Yahei", 24)
    layerTitle:addChild(cclf)
    local tbTitleSize = cclf:getTextureRect().size
    cclf:setPosition(5 + tbTitleSize.width / 2 , tbVisibleSize.height - tbTitleSize.height / 2 - 10)

    local pHero = CCSprite:createWithSpriteFrame(frame0)
    Character:SetSpriteDirection(pHero, Def.DIR_DOWN)
    pHero:setScale(0.7)
    local tbHeroSize = pHero:getTextureRect().size
    pHero:setPosition(10 + tbTitleSize.width + tbHeroSize.width / 2, tbVisibleSize.height - (tbHeroSize.height * 0.7 / 2 ))
    layerTitle:addChild(pHero)

    local cclfHP = CCLabelTTF:create("100 / 100", "Microsoft Yahei", 16)
    layerTitle:addChild(cclfHP)
    local tbHPSize = cclfHP:getTextureRect().size
    cclfHP:setPosition(15 + tbTitleSize.width + tbHeroSize.width +  tbHPSize.width / 2, tbVisibleSize.height - tbHPSize.height / 2 - 10)

    sceneGame:addChild(layerTitle, 10)

    self.tbTitle["State"] = cclf
    self.tbTitle["Head"] = pHero
    self.tbTitle["HP"] = cclfHP
    self:UpdateTitle()
end

function GameMgr:UpdateHP()

end

function GameMgr:UpdateTitle()
	if not self.tbTitle or not self.tbTitle["State"] then
		return
	end
	local szDesc = self:GetStateDesc()
	self.tbTitle["State"]:setString(szDesc)
end