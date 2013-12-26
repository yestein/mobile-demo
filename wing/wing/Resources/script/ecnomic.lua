--===================================================
-- File Name    : ecnomic.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-12-24 23:08:52
-- Description  :
-- Modify       :
--===================================================

function Ecnomic:Init()
	self:RegisterEvent()
end

function Ecnomic:Uninit()
	self:UnRegisterEvent()
end

function Ecnomic:RegisterEvent()
	if not self.nRegCharacterDie then
		Event:RegistEvent("CharacterDie", self.OnCharacterDie, self)
	end
end

function Ecnomic:UnRegisterEvent()
	if self.nRegCharacterDie then
		Event:UnRegistEvent("CharacterDie", self.nRegCharacterDie )
		self.nRegCharacterDie = nil
	end
end

function Ecnomic:OnCharacterDie(dwCharacterId, dwLancherId)
	if not dwLancherId then
		return
	end
	if Lib:IsHero(dwCharacterId) == 1 or Lib:IsHero(dwLancherId) ~= 1 then
        return
    end
    local tbCharacter = GameMgr:GetCharacterById(dwCharacterId)
    if tbCharacter then
    	local nChangeCount = math.random(1, 10)
    	Player:ChangeResouce("Gold", nChangeCount)
    end
end