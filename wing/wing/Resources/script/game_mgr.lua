--=======================================================================
-- �ļ�������game_mgr.lua
-- �����ߡ���yulei(yulei1@kingsoft.com)
-- ����ʱ�䣺2013-09-26 13:40:31
-- ����������
-- �޸��б�
--=======================================================================

function GameMgr:Init()
	self.tbCharacterMap = {}
end

function GameMgr:AddCharacter(dwId, tbCharacter)
	self.tbCharacterMap[dwId] = tbCharacter
end

function GameMgr:GetCharacterById(dwId)
	return self.tbCharacterMap[dwId]
end

function GameMgr:RemoveCharacter(dwId)
	local pSprite = self.tbCharacterMap[dwId].pSprite
	if pSprite then
		self:RemoveSpriteFromBg(pSprite)
	end	
	self.tbCharacterMap[dwId] = nil
end

function GameMgr:Start()
	for dwId, tbCharacter in pairs(self.tbCharacterMap) do
		tbCharacter:Start()
	end
end

function GameMgr:Reset()
	for dwId, tbCharacter in pairs(self.tbCharacterMap) do
		tbCharacter:Reset()
	end
end


function GameMgr:GetGameScene()
	return self.sceneGame	
end

function GameMgr:GetLayerBg()
	return self.layerBG	
end

function GameMgr:GetLayerMenu()
	return self.layerMenu
end

function GameMgr:RemoveSpriteFromBg(pSprite)
	self.layerBG:removeChild(pSprite, true)
end