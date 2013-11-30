--=======================================================================
-- File Name    : character_mgr.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-11-28 18:00:31
-- Description  :
-- Modify       :
--=======================================================================


function GameMgr:AddCharacter(dwId, tbCharacter)
	self.tbCharacterMap[dwId] = tbCharacter
end

function GameMgr:GetCharacterById(dwId)
	return self.tbCharacterMap[dwId]
end

function GameMgr:RemoveCharacter(szSceneName, dwId)
	if not self.tbCharacterMap[dwId] then
		return 0
	end
	local pSprite = self.tbCharacterMap[dwId].pSprite
	if pSprite then
		self:RemoveSprite(szSceneName, pSprite)
	end	
	self.tbCharacterMap[dwId] = nil
	return 1
end

function GameMgr:RemoveSprite(szSceneName, pSprite)
	local tbScene = SceneMgr:GetScene(szSceneName)
	tbScene:RemoveSprite(pSprite)
end