--=======================================================================
-- File Name    : performance.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-12-05 21:16:23
-- Description  :
-- Modify       :
--=======================================================================

Performance.MAX_DISPLAY_DAMAGE = 20

local szFlyLabelFont = "Courier"
if OS_WIN32 then
    szFlyLabelFont = "Microsoft Yahei"
end
print(szFlyLabelFont)

function Performance:Init(layer)

    self.tbFlyLabel = {}
    self.nDamageIndex = 1
	for i = 1, self.MAX_DISPLAY_DAMAGE do
		local labelFly = CCLabelTTF:create("-100", szFlyLabelFont, 18)
        layer:addChild(labelFly, 10)
        labelFly:setVisible(false)
        self.tbFlyLabel[i] = labelFly
	end
	self.nodeFight = CCSpriteBatchNode:create(Def.szFightImg)
	self.nodeFight:setPosition(0, 0)
	layer:addChild(self.nodeFight, 10)
	self:UnRegistEvent()
	self:RegistEvent()
end

function Performance:Uninit()
end

function Performance:GetAvaiableFlyLabel()
	local label = self.tbFlyLabel[self.nDamageIndex]

	self.nDamageIndex = self.nDamageIndex + 1
	if self.nDamageIndex > self.MAX_DISPLAY_DAMAGE then
		self.nDamageIndex = self.nDamageIndex - self.MAX_DISPLAY_DAMAGE
	end
	return label
end

function Performance:GetNodeFight()
	return self.nodeFight
end

function Performance:SetSpriteDirection(pSprite, nDirection)
	local frameWidth = 36
	local frameHeight = 48

	local Texture = pSprite:getTexture()
	local animFrames = CCArray:create()
	for i = 1, 4 do
		local rect = CCRectMake((i - 1) * frameWidth, frameHeight * Def.tbTextureRow[nDirection], frameWidth, frameHeight)
	    local frame = CCSpriteFrame:createWithTexture(Texture, rect)
	    animFrames:addObject(frame)
	end
    local animation = CCAnimation:createWithSpriteFrames(animFrames, 0.15)
    local animate = CCAnimate:create(animation)
    pSprite:stopAllActions()
    pSprite:runAction(CCRepeatForever:create(animate))
end

function Performance:RegistEvent()
	if not self.nRegHPChanged then
		self.nRegHPChanged = Event:RegistEvent("CharacterHPChanged", self.OnCharacterHPChanged, self)
	end

	if not self.nRegPhysicAttack then
		self.nRegPhysicAttack = Event:RegistEvent("CharacterPhyiscAttack", self.OnCharacterPhyiscAttack, self)
	end
	if not self.nRegHeroAdd then
		Event:RegistEvent("HeroAdd", self.OnHeroAdd, self)
	end
	if not self.nRegMonsterAdd then
		Event:RegistEvent("MonsterAdd", self.OnMonsterAdd, self)
	end
end

function Performance:UnRegistEvent()
	if self.nRegHPChanged then
		Event:UnRegistEvent("CharacterHPChanged", self.nRegHPChanged )
		self.nRegHPChanged = nil
	end

	if self.nRegPhysicAttack then
		Event:UnRegistEvent("CharacterPhyiscAttack", self.nRegPhysicAttack )
		self.nRegPhysicAttack = nil
	end

	if self.nRegHeroAdd then
		Event:UnRegistEvent("HeroAdd", self.nRegHeroAdd )
		self.nRegHeroAdd = nil
	end

	if self.nRegMonsterAdd then
		Event:UnRegistEvent("MonsterAdd", self.nRegMonsterAdd )
		self.nRegMonsterAdd = nil
	end
end

function Performance:OnHeroAdd(dwHeroId)
	return self:OnCharacterAdd(dwHeroId, CCRectMake(0, 1, 20, 1))
end

function Performance:OnMonsterAdd(dwMonsterId)
	return self:OnCharacterAdd(dwMonsterId, CCRectMake(0, 0, 20, 1))
end

function Performance:OnCharacterAdd(dwCharacterId, ccRect)
	local tbCharacter = GameMgr:GetCharacterById(dwCharacterId)
	if tbCharacter then
		local pSprite = tbCharacter.pSprite
		local tbSpriteSize = pSprite:getTextureRect().size
		local spriteHP = CCSprite:create(Def.szBarImg, ccRect)
		local spriteHPBG = CCSprite:create(Def.szBarImg, CCRectMake(0, 3, 20, 1))
    	local progressHP = CCProgressTimer:create(spriteHP)
    	local progressSize = spriteHP:getTextureRect().size
    	progressHP:setPercentage(100)
	    progressHP:setMidpoint(CCPoint:new(0, 0.5))
	    progressHP:setBarChangeRate(CCPoint:new(1, 0))
	    progressHP:setType(1)

    	progressHP:setAnchorPoint(CCPoint:new(0.5, 1))
    	spriteHPBG:setAnchorPoint(CCPoint:new(0.5, 1))
	    progressHP:setScaleX(36 * 0.7 / progressSize.width)
	    spriteHPBG:setScaleX(36 * 0.7 / progressSize.width)
	    progressHP:setScaleY(4)
	    spriteHPBG:setScaleY(4)
	    progressHP:setPosition(18, tbSpriteSize.height)
	    spriteHPBG:setPosition(18, tbSpriteSize.height)
	    progressHP:setVisible(false)
	    spriteHPBG:setVisible(false)
	    pSprite:addChild(spriteHPBG)
	    pSprite:addChild(progressHP)	    
	    tbCharacter.progressHP = progressHP
	    tbCharacter.spriteHPBG = spriteHPBG
	end
end

function Performance:OnCharacterHPChanged(dwCharacterId, nBeforeHP, nAfterHP, nMaxHP)
	local nDamage = nAfterHP - nBeforeHP
	local color = nil
	local szMsg = nil
	if nDamage == 0 then
		return
	elseif nDamage < 0 then
		color = Def.tbColor["red"]
		szMsg = tostring(nDamage)
	elseif nDamage > 0 then
		color = Def.tbColor["red"]
		szMsg = "+"..tostring(nDamage)
	end

	local tbCharacter = GameMgr:GetCharacterById(dwCharacterId)
	if not tbCharacter then
		return
	end
	local pSprite = tbCharacter.pSprite
	if not pSprite then
		return
	end

	local progressHP = tbCharacter.progressHP
	if progressHP then
		progressHP:setVisible(true)
		tbCharacter.spriteHPBG:setVisible(true)
		progressHP:setPercentage(nAfterHP * 100 / nMaxHP)
	end

	local nX, nY = pSprite:getPosition()
	local label = self:GetAvaiableFlyLabel()
	if not label then
		return
	end
	label:setColor(color)
	label:setString(szMsg)	
	label:setVisible(true)
	label:setPosition(nX, nY + 10)
	local action = CCSpawn:createWithTwoActions(CCFadeOut:create(1), CCMoveBy:create(1, ccp(0, 40)))
	label:runAction(action)
end

function Performance:OnCharacterPhyiscAttack(dwLancherId, dwTargetId, nDamage)
	local tbLancher = GameMgr:GetCharacterById(dwLancherId)
	if not tbLancher then
		assert(false)
		return
	end
	local tbTarget = GameMgr:GetCharacterById(dwTargetId)
	if not tbTarget then
		assert(false)
		return
	end
	local pLancherSprite = tbLancher.pSprite
	if not pLancherSprite then
		assert(false)
		return
	end
	local pTargetSprite = tbTarget.pSprite
	if not pTargetSprite then
		assert(false)
		return
	end

	local nLancherX, nLancherY = pLancherSprite:getPosition()
	local nTargetX, nTargetY = pTargetSprite:getPosition()

	-- local nDisPlayX = math.floor((nLancherX + nTargetX) / 2)
	-- local nDisPlayY = math.floor((nLancherY + nTargetY) / 2)
	self:GenerateFightFlag(nTargetX, nTargetY)
end

function Performance:GenerateFightFlag(nX, nY)
	local nodeFight = self:GetNodeFight()
	if not nodeFight then
		assert(false)
		return
	end
	local textureFight = nodeFight:getTexture()
	local pSprite = CCSprite:createWithTexture(textureFight)
	
	
	local tbTextureSize = pSprite:getTextureRect().size
	local nFrameWidth = tbTextureSize.width / 2
	local nFrameHeight = tbTextureSize.height
	local spriteFrames = CCArray:create()	
	for i = 1, 2 do
		local rect = CCRectMake((i - 1) * nFrameWidth, 0, nFrameWidth, nFrameHeight)
    	local frame = CCSpriteFrame:createWithTexture(textureFight, rect)
    	spriteFrames:addObject(frame)
    end
    local animation = CCAnimation:createWithSpriteFrames(spriteFrames, 0.125)
    local animate = CCAnimate:create(animation)
    pSprite:stopAllActions()
    pSprite:runAction(CCRepeatForever:create(animate))

	nodeFight:addChild(pSprite)
	pSprite:setPosition(nX, nY)

    local nRegId = nil
    local function tick()
	    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(nRegId)
	    nodeFight:removeChild(pSprite, true)
	end
	nRegId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick, 0.25, false)
	
	return pSprite
end
