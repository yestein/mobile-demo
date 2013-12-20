--=======================================================================
-- File Name    : title.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-11-28 20:57:43
-- Description  :
-- Modify       :
--=======================================================================

GameMgr.MSG_MAX_COUNT = 3

local szTitleFontName = "MarkerFelt-Thin"

if OS_WIN32 then
    szTitleFontName = "Microsoft Yahei"
end

function GameMgr:InitTitle()
	self.tbTitle = {}
    self.tbResurce = {}
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
    sceneGame:addChild(layerTitle, Def.ZOOM_LEVEL_TITLE)

    local pBg = CCSprite:create(Def.szTitleFile)
    layerTitle:addChild(pBg)
    local tbBgSize = pBg:getTextureRect().size
    pBg:setPosition(tbBgSize.width / 2 , tbVisibleSize.height - tbBgSize.height / 2)

    local cclf = CCLabelTTF:create("当前模式", szTitleFontName, 24)
    layerTitle:addChild(cclf)
    local tbTitleSize = cclf:getTextureRect().size
    cclf:setAnchorPoint(CCPoint:new(1, 0))
    cclf:setPosition(tbVisibleSize.width , 0)

    self.tbSysMsg = {}
    for i = 1, GameMgr.MSG_MAX_COUNT do
        local labelSysMsg = CCLabelTTF:create("系统提示", szTitleFontName, 18)
        layerTitle:addChild(labelSysMsg)
        local tbMsgSize = labelSysMsg:getTextureRect().size
        labelSysMsg:setPosition(tbVisibleSize.width / 2, tbVisibleSize.height / 2 - (2 - i) * tbMsgSize.height)
        labelSysMsg:setVisible(false)
        self.tbSysMsg[i] = labelSysMsg
    end
    self.nMsgIndex = 1

    local tbTemp = nil
    if OS_WIN32 then
        tbTemp = {
            {szImageFile = "image/ui/digpoint.png", szResourceName = "DigPoint"},
            {szImageFile = "image/ui/gold.png", szResourceName = "Gold"},
            {szImageFile = "image/ui/magic.png", szResourceName = "Magic"},
        }
    else
        tbTemp = {
            {szImageFile = "digpoint.png", szResourceName = "DigPoint"},
            {szImageFile = "gold.png", szResourceName = "Gold"},
            {szImageFile = "magic.png", szResourceName = "Magic"},
        }
    end

    local nHeight = 20
    local nWidth = 20
    self.nSpriteX = nWidth / 2 + 30
    self.nSpriteY = tbVisibleSize.height - nHeight / 2
    for _, tb in ipairs(tbTemp) do
        local spriteIcon = CCSprite:create(tb.szImageFile)
        local labelValue = CCLabelTTF:create("10000000", szTitleFontName, 16)
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
        self.tbResurce[tb.szResourceName] = {icon = spriteIcon, value = labelValue}
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
    Performance:SetSpriteDirection(pCopySprite, Def.DIR_DOWN)
    pCopySprite:setScale(0.6)
    local tbVisibleSize = CCDirector:sharedDirector():getVisibleSize()
    local tbSpriteSize = pSprite:getTextureRect().size
    pCopySprite:setAnchorPoint(CCPoint:new(0, 0))
    pCopySprite:setPosition(self.nHeroX, tbVisibleSize.height - dwHeroId * tbSpriteSize.height * 0.6)
    self.layerTitle:addChild(pCopySprite)

    local spriteHP = CCSprite:create(Def.szBarImg, CCRectMake(0, 0, 20, 1))
    local progressHP = CCProgressTimer:create(spriteHP)
    local tbProgressHPSize = spriteHP:getTextureRect().size
    progressHP:setAnchorPoint(CCPoint:new(0.5, 0))
    progressHP:setMidpoint(CCPoint:new(0, 0.5))
    progressHP:setBarChangeRate(CCPoint:new(1, 0))
    local nXScale = 120 / tbProgressHPSize.width
    progressHP:setScaleX(nXScale)
    local nYScale = 20 / tbProgressHPSize.height
    progressHP:setScaleY(nYScale)
    progressHP:setType(1)
    local nPosX = self.nHeroX + tbSpriteSize.width / 2 + 10 + tbProgressHPSize.width * nXScale / 2
    local nPosY = tbVisibleSize.height - dwHeroId * tbSpriteSize.height * 0.6
    progressHP:setPosition(nPosX, nPosY)

    local spriteHPBG = CCSprite:create(Def.szBarImg, CCRectMake(0, 1, 20, 1))
    spriteHPBG:setAnchorPoint(CCPoint:new(0.5, 0))
    spriteHPBG:setScaleX(nXScale)
    spriteHPBG:setScaleY(nYScale)
    spriteHPBG:setPosition(nPosX, nPosY)

    self.layerTitle:addChild(spriteHPBG)
    self.layerTitle:addChild(progressHP)

    local szMsg = string.format("%d / %d", tbHero:GetProperty("CurHP"), tbHero:GetProperty("MaxHP"))
    local cclfHP = CCLabelTTF:create(szMsg, szTitleFontName, 16)
    cclfHP:setAnchorPoint(CCPoint:new(0.5, 0))
    self.layerTitle:addChild(cclfHP)
    local tbHPSize = cclfHP:getTextureRect().size
    cclfHP:setPosition(nPosX + (tbProgressHPSize.width * nXScale - tbHPSize.width) / 2, nPosY)
    self.tbHeroHP[dwHeroId] = {
        spriteHead = pCopySprite,
        labelHP = cclfHP,
        progressHP = progressHP,
        spriteHPBG = spriteHPBG,
    }

    progressHP:setPercentage(100)
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
    self.layerTitle:removeChild(tbHero.progressHP, true)
    self.layerTitle:removeChild(tbHero.spriteHPBG, true)
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
    tbHP.progressHP:setPercentage(nCurHP * 100 / nMaxHP)
    Event:FireEvent("TitleHPUpdate", dwHeroId, szHP)

end

function GameMgr:RegistEvent()
    Event:RegistEvent("HeroAdd", self.OnHeroAdd, self)
    Event:RegistEvent("CharacterHPChanged", self.OnCharacterReceiveDamage, self)
    Event:RegistEvent("CharacterDie", self.OnCharacterDie, self)
    Event:RegistEvent("GameMgrSetState", self.OnStateChanged, self)
    Event:RegistEvent("SetResouce", self.OnResourceChanged, self)
end

function GameMgr:OnStateChanged(nState)
	if not self.tbTitle or not self.tbTitle["State"] then
		return
	end
	local szDesc = self:GetStateDesc(nState) or "未知状态"
	self.tbTitle["State"]:setString(szDesc)
    for dwId, _ in pairs(self.tbWaitToRemoveHP) do
        self:RemoveHeroHP(dwId)
    end
    self.tbWaitToRemoveHP = {}
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

function GameMgr:OnCharacterReceiveDamage(dwCharacterId)
    if Lib:IsHero(dwCharacterId) ~= 1 then
        return
    end
    self:UpdateHeroHP(dwCharacterId)    
end

function GameMgr:OnResourceChanged(szResourceName, nNewValue, bMax)
    local tbResurce = self.tbResurce[szResourceName]
    if not tbResurce then
        return
    end
    local labelValue = tbResurce.value
    labelValue:setString(tostring(nNewValue))
end

function GameMgr:SysMsg(szMsg, szColor)
    local tbVisibleSize = CCDirector:sharedDirector():getVisibleSize()
    if not szColor then
        szColor = "white"
    end
    for i = 1, self.MSG_MAX_COUNT do
        local nIndex = self.nMsgIndex - i + 1
        if nIndex <= 0 then
            nIndex = nIndex + self.MSG_MAX_COUNT
        end
        local labelSysMsg = self.tbSysMsg[nIndex]
        if i == 1 then
            local color = Def.tbColor[szColor]
            labelSysMsg:setVisible(true)
            labelSysMsg:setString(szMsg)
            labelSysMsg:setColor(color)
            labelSysMsg:runAction(CCFadeOut:create(3))
        end
        local tbMsgSize = labelSysMsg:getTextureRect().size
        labelSysMsg:setPosition(tbVisibleSize.width / 2, tbVisibleSize.height / 2 + (i + 3) * tbMsgSize.height)
    end
    self.nMsgIndex = self.nMsgIndex + 1
    if self.nMsgIndex > self.MSG_MAX_COUNT then
        self.nMsgIndex = self.nMsgIndex - self.MSG_MAX_COUNT
    end
end