--=======================================================================
-- File Name    : title.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-11-28 20:57:43
-- Description  :
-- Modify       :
--=======================================================================

function GameMgr:InitTitle()
	self.tbTitle = {}
    self.tbHeroHP = {}
    self.tbWaitToRemoveHP = {}
	local sceneGame = SceneMgr:GetSceneObj("GameScene")
	if not sceneGame then
		return
	end
	local tbVisibleSize = CCDirector:sharedDirector():getVisibleSize()
	local layerTitle = CCLayer:create()
    self.layerTitle = layerTitle
    layerTitle:setPosition(0, 0)
    sceneGame:addChild(layerTitle, 2)

    local pBg = CCSprite:create(Def.szTitleFile)
    layerTitle:addChild(pBg)
    local tbBgSize = pBg:getTextureRect().size
    pBg:setPosition(tbBgSize.width / 2 , tbVisibleSize.height - tbBgSize.height / 2)

    local cclf = CCLabelTTF:create("当前模式", "Microsoft Yahei", 24)
    layerTitle:addChild(cclf)
    local tbTitleSize = cclf:getTextureRect().size
    cclf:setPosition(tbTitleSize.width / 2, tbVisibleSize.height - tbBgSize.height / 2)

    local tbTemp = {
        {szImageFile = "digpoint.png", szResourceName = "DigPoint"},
        {szImageFile = "gold.png", szResourceName = "Gold"},
        {szImageFile = "magic.png", szResourceName = "Magic"},
    }

    local nHeight = 20
    local nWidth = 20
    self.nSpriteX = tbTitleSize.width + nWidth / 2
    self.nSpriteY = tbVisibleSize.height - nHeight / 2
    for _, tb in ipairs(tbTemp) do
        local spriteIcon = CCSprite:create(tb.szImageFile)
        local labelValue = CCLabelTTF:create("10000000", "Microsoft Yahei", 16)
        layerTitle:addChild(spriteIcon)
        layerTitle:addChild(labelValue)
        spriteIcon:setPosition(self.nSpriteX, self.nSpriteY)
        spriteIcon:setScale(0.7)
        labelValue:setPosition(self.nSpriteX + nWidth, self.nSpriteY)
        labelValue:setAnchorPoint(CCPoint:new(0, 0.5))
        if not self.nHeroX then
            local tbValueSize = labelValue:getTextureRect().size
            self.nHeroX = self.nSpriteX + nWidth + tbValueSize.width
        end
        self.tbTitle[tb.szResourceName] = labelValue
        self.nSpriteY = self.nSpriteY - nHeight
    end

    self.tbTitle["State"] = cclf
    self:RegistEvent()
    Event:FireEvent("TitleInit")
end

function GameMgr:AddHeroHP(dwHeroId)
    if self.tbHeroHP[dwHeroId] then
        return 0
    end
    local tbHero = self:GetCharacterById(dwHeroId)
    local pSprite = tbHero.pSprite
    local pCopySprite = CCSprite:createWithTexture(pSprite:getTexture())
    Character:SetSpriteDirection(pCopySprite, Def.DIR_DOWN)
    pCopySprite:setScale(0.7)
    local tbVisibleSize = CCDirector:sharedDirector():getVisibleSize()
    local tbSpriteSize = pSprite:getTextureRect().size
    pCopySprite:setAnchorPoint(CCPoint:new(0, 0))
    pCopySprite:setPosition(self.nHeroX, tbVisibleSize.height - dwHeroId * tbSpriteSize.height * 0.7)
    self.layerTitle:addChild(pCopySprite)

    local szMsg = string.format("%d / %d", tbHero:GetProperty("CurHP"), tbHero:GetProperty("MaxHP"))
    local cclfHP = CCLabelTTF:create(szMsg, "Microsoft Yahei", 18)
    cclfHP:setAnchorPoint(CCPoint:new(0, 0))
    self.layerTitle:addChild(cclfHP)
    local tbHPSize = cclfHP:getTextureRect().size
    cclfHP:setPosition(self.nHeroX + tbSpriteSize.width + 1, tbVisibleSize.height - dwHeroId * tbSpriteSize.height * 0.7)
    self.tbHeroHP[dwHeroId] = {
        spriteHead = pCopySprite,
        labelHP = cclfHP,
    }
    Event:FireEvent("TitleHPAdd", dwHeroId, szMsg)
    return 1
end

function GameMgr:RemoveHeroHP(dwHeroId)
    local tbHero = self.tbHeroHP[dwHeroId]
    if not tbHero then
        return 0
    end
    self.layerTitle:removeChild(tbHero.spriteHead, true)
    self.layerTitle:removeChild(tbHero.labelHP, true)
    self.tbHeroHP[dwHeroId] = nil
    Event:FireEvent("TitleHPRemove", dwHeroId)
    return 1
end

function GameMgr:UpdateHeroHP(dwHeroId)
    local tbHP = self.tbHeroHP[dwHeroId]
    if not tbHP then
        return
    end
    local tbHero = self:GetCharacterById(dwHeroId)
    local nCurHP, nMaxHP = tbHero:GetProperty("CurHP"), tbHero:GetProperty("MaxHP")
    local szHP = string.format("%d / %d", nCurHP, nMaxHP)
    tbHP.labelHP:setString(szHP)
    Event:FireEvent("TitleHPUpdate", dwHeroId, szHP)
end

function GameMgr:RegistEvent()
    Event:RegistEvent("HeroAdd", self.OnHeroAdd, self)
    Event:RegistEvent("CharacterBeAttacked", self.OnCharacterBeAttacked, self)
    Event:RegistEvent("CharacterDie", self.OnCharacterDie, self)
    Event:RegistEvent("GameMgrSetState", self.OnStateChanged, self)
    Event:RegistEvent("SetResouce", self.OnResourceChanged, self)
end

function GameMgr:OnStateChanged(nState)
	if not self.tbTitle or not self.tbTitle["State"] then
		return
	end
	local szDesc = self:GetStateDesc(nState)
	self.tbTitle["State"]:setString(szDesc)
    for dwId, _ in pairs(self.tbWaitToRemoveHP) do
        self:RemoveHeroHP(dwId)
    end
    self.tbWaitToRemoveHP = {}
    Event:FireEvent("TitleStateUpdate", szDesc)
end

function GameMgr:OnHeroAdd(dwHeroId)
    assert(self:AddHeroHP(dwHeroId) == 1)
end

function GameMgr:OnCharacterDie(dwCharacterId)
    if Lib:IsHero(dwCharacterId) ~= 1 then
        return
    end
    self.tbWaitToRemoveHP[dwCharacterId] = 1
    Event:FireEvent("TitleHPWaitForRemove", dwCharacterId)
end

function GameMgr:OnCharacterBeAttacked(dwCharacterId)
    if Lib:IsHero(dwCharacterId) ~= 1 then
        return
    end
    self:UpdateHeroHP(dwCharacterId)    
end

function GameMgr:OnResourceChanged(szResourceName, nNewValue, bMax)
    
end