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
	local frameWidth = 36
	local frameHeight = 48
	local textureHero = CCTextureCache:sharedTextureCache():addImage(Def.szHeroFile)
	local rect = CCRectMake(0, frameHeight, frameWidth, frameHeight)
	local frame0 = CCSpriteFrame:createWithTexture(textureHero, rect)

	local tbVisibleSize = CCDirector:sharedDirector():getVisibleSize()
	local layerTitle = CCLayer:create()
    self.layerTitle = layerTitle
    layerTitle:setPosition(0, 0)

    local pBg = CCSprite:create(Def.szTitleFile)
    layerTitle:addChild(pBg)
    local tbBgSize = pBg:getTextureRect().size
    pBg:setPosition(tbBgSize.width / 2 , tbVisibleSize.height - tbBgSize.height / 2)

    local cclf = CCLabelTTF:create("当前模式", "Microsoft Yahei", 24)
    layerTitle:addChild(cclf)
    local tbTitleSize = cclf:getTextureRect().size
    cclf:setPosition(5 + tbTitleSize.width / 2 , tbVisibleSize.height - tbTitleSize.height / 2 - 10)
    sceneGame:addChild(layerTitle, 2)
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
    print(tbSpriteSize.width / 2,tbSpriteSize.height / 2)
    pCopySprite:setPosition(100 + tbSpriteSize.width / 2, tbVisibleSize.height - tbSpriteSize.height / 2)
    self.layerTitle:addChild(pCopySprite)

    local szMsg = string.format("%d / %d", tbHero:GetProperty("CurHP"), tbHero:GetProperty("MaxHP"))
    local cclfHP = CCLabelTTF:create(szMsg, "Microsoft Yahei", 16)
    self.layerTitle:addChild(cclfHP)
    local tbHPSize = cclfHP:getTextureRect().size
    cclfHP:setPosition(105 + tbSpriteSize.width +  tbHPSize.width / 2, tbVisibleSize.height - tbSpriteSize.height / 2 - 5)
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