--=======================================================================
-- File Name    : performance.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-12-05 21:16:23
-- Description  :
-- Modify       :
--=======================================================================

Performance.MAX_DISPLAY_DAMAGE = 20

local szDamageFontName = "Courier"
if OS_WIN32 then
    szDamageFontName = "Microsoft Yahei"
end
print(szDamageFontName)

function Performance:Init(layer)

    self.tbDamage = {}
    self.nDamageIndex = 1
	for i = 1, self.MAX_DISPLAY_DAMAGE do
		local labelDamage = CCLabelTTF:create("-100", szDamageFontName, 18)
        layer:addChild(labelDamage, 10)
        labelDamage:setVisible(false)
        self.tbDamage[i] = labelDamage        
	end

	self:UnRegistEvent()
	self:RegistEvent()
end

function Performance:Uninit()
end

function Performance:GetAvaiableDamageLabel()
	local label = self.tbDamage[self.nDamageIndex]

	self.nDamageIndex = self.nDamageIndex + 1
	if self.nDamageIndex > self.MAX_DISPLAY_DAMAGE then
		self.nDamageIndex = self.nDamageIndex - self.MAX_DISPLAY_DAMAGE
	end
	return label
end

function Performance:RegistEvent()
	if not self.nRegBeAttack then
		self.nRegBeAttack = Event:RegistEvent("CharacterBeAttacked", self.OnCharacterBeAttacked, self)
	end
end

function Performance:UnRegistEvent()
	if self.nRegBeAttack then
		Event:UnRegistEvent("CharacterBeAttacked", self.nRegBeAttack )
		self.nRegBeAttack = nil
	end
end


function Performance:OnCharacterBeAttacked(dwCharacterId,  nBeforeHP, nAfterHP)
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

	local nX, nY = pSprite:getPosition()
	local label = self:GetAvaiableDamageLabel()
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
