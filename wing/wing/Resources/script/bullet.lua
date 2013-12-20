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

if OS_WIN32 then
	Bullet.tbBulletCfg = {
		["LightBall"] = {szImgFile = "image/lightball.png", szCreateFunc = "CreateLightBall"},
		["Fire"]      = {szImgFile = "image/fire.png", szCreateFunc = "CreateFire"},
	}
else
	Bullet.tbBulletCfg = {
		["LightBall"] = {szImgFile = "lightball.png", szCreateFunc = "CreateLightBall"},
		["Fire"]      = {szImgFile = "fire.png", szCreateFunc = "CreateFire"},
	}
end

function Bullet:Init()
	self.tbBulletList = {}
	self.tbBulletNodeList = {}
	for szBulletType, tbCfg in pairs(self.tbBulletCfg) do
		local bulletNode = CCSpriteBatchNode:create(tbCfg.szImgFile)
		bulletNode:setPosition(0, 0)
		
		self.tbBulletNodeList[szBulletType] = bulletNode
	end

	local function OnActive()
		for dwBulletId, tbBullet in pairs(self.tbBulletList) do
			local nDirection = tbBullet.nDirection
			local tbProperty = tbBullet.tbProperty
			local nSpeedMulti = GameMgr:GetSpeedMulti()
			local nMoveSpeed = tbProperty.nMoveSpeed * nSpeedMulti
			local tbPosOffset = Def.tbMove[nDirection]
			if tbPosOffset then
				local pSprite = tbBullet.pSprite
				local nX, nY = unpack(tbPosOffset)
				local x, y = pSprite:getPosition()
				local nNewX, nNewY = x + nX * nMoveSpeed, y + nY * nMoveSpeed
				pSprite:setPosition(nNewX, nNewY)
				local tbSize = pSprite:getTextureRect().size
				local nCheckX, nCheckY = nNewX + nX * tbSize.width / 2, nNewY + nY * tbSize.height / 2
				local nLogicX, nLogicY = Lib:GetLogicPosByPosition(nCheckX, nCheckY)
				if Maze:GetData(nLogicX, nLogicY) == Maze.MAP_BLOCK  then
					tbBullet:Uninit()
					self.tbBulletList[dwBulletId] = nil
					return
				end
				local tbUnit = Maze:GetUnit(nLogicX, nLogicY)
				for dwTargetId, _ in pairs(tbUnit) do
					local tbCharacter = GameMgr:GetCharacterById(dwTargetId)
					if tbCharacter then
						if tbBullet:JudgeCollide(nLogicX, nLogicY, dwTargetId) == 1  then
							local nDamage = tbBullet:CalcDamage(tbCharacter)
							tbCharacter:ReceiveDamage(nDamage)
							tbBullet:RecordTarget(dwTargetId)
							if tbBullet.tbProperty.bAOE ~= 1 then
								tbBullet:Uninit()
								self.tbBulletList[dwBulletId] = nil
								break
							end
						end
					end
				end
			end
	    end
	end
	CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(OnActive, 0, false)
	return self.tbBulletNodeList
end

function Bullet:GetBulletNode(szType)
	return self.tbBulletNodeList[szType]
end

function Bullet:AddBullet(nX, nY, nDirection, tbProperty)
	local tbBullet = Lib:NewClass(tbBulletClass)
	local dwId = Accumulator()
	tbBullet.dwId = dwId
	tbBullet:Init(nX, nY, tbProperty)
	tbBullet.nDirection = nDirection
	self.tbBulletList[dwId] = tbBullet
	return dwId
end

function Bullet.NotSameCamp(dwLancherId, dwTargetId)
	if Lib:IsHero(dwLancherId) == Lib:IsHero(dwTargetId) then
		return 0
	else
		return 1
	end
end

function Bullet:CreateLightBall(bulletNode)
	return CCSprite:createWithTexture(bulletNode:getTexture())
end

function Bullet:CreateFire(bulletNode)
	local textureBullet = bulletNode:getTexture()
	local nFrameWidth = textureBullet:getPixelsWide() / 4
	local nFrameHeight = textureBullet:getPixelsHigh() / 4
	local rect = CCRectMake(0, nFrameHeight, nFrameWidth, nFrameHeight)
	local frameRaw = CCSpriteFrame:createWithTexture(textureBullet, rect)
    local pSprite = CCSprite:createWithSpriteFrame(frameRaw)
	local spriteFrames = CCArray:create()	
	for i = 1, 4 do
		local rect = CCRectMake((i - 1) * nFrameWidth, nFrameHeight, nFrameWidth, nFrameHeight)
    	local frame = CCSpriteFrame:createWithTexture(textureBullet, rect)
    	spriteFrames:addObject(frame)
    end
    local animation = CCAnimation:createWithSpriteFrames(spriteFrames, 0.15)
    local animate = CCAnimate:create(animation)
    --pSprite:stopAllActions()
    pSprite:runAction(CCRepeatForever:create(animate))
    -- pSprite:setScale(0.5)

    return pSprite
end	

Bullet.tbJudgeCollide = {
	["Enemy"] = Bullet.NotSameCamp,
}

function tbBulletClass:Init(nX, nY, tbProperty)
	if not tbProperty.szBulletType then
		assert(false)
		return
	end
	local szBulletType = tbProperty.szBulletType
	local bulletNode = Bullet:GetBulletNode(szBulletType)
	local szfuncName = Bullet.tbBulletCfg[szBulletType].szCreateFunc
	if not szfuncName then
		return
	end
	local func = Bullet[szfuncName]
	if not func then
		assert(false)
		return
	end
	local pSprite = func(self, bulletNode)
	if not pSprite then
		assert(false)
		return
	end
	pSprite:setPosition(nX, nY)
	bulletNode:addChild(pSprite)
	self.pSprite = pSprite
	self.tbProperty = tbProperty
	self.tbRecordTarget = {}
end

function tbBulletClass:JudgeCollide(nLogicX, nLogicY, dwTargetId)
	if self:IsInRecord(dwTargetId) then
		return 0
	end
	local func = Bullet.tbJudgeCollide[self.tbProperty.szTargetType]
	return func(self.tbProperty.dwLancherId, dwTargetId)
end

function tbBulletClass:CalcDamage(tbCharacter)
	local nTargetDefense = tbCharacter:GetProperty("Defense")
	local nDamage = math.floor(self.tbProperty.Damage * (100 / (100 + nTargetDefense)))
	return nDamage
end

function tbBulletClass:RecordTarget(dwTargetId)
	self.tbRecordTarget[dwTargetId] = 1
end

function tbBulletClass:IsInRecord(dwTargetId)
	return self.tbRecordTarget[dwTargetId]
end

function tbBulletClass:RemoveRecordTarget(dwTargetId)
	self.tbRecordTarget[dwTargetId] = nil
end

function tbBulletClass:Uninit()
	local bulletNode = Bullet:GetBulletNode(self.tbProperty.szBulletType)
	bulletNode:removeChild(self.pSprite, true)
end

