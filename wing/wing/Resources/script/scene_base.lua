--=======================================================================
-- File Name    : scene_base.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-11-29 21:16:43
-- Description  :
-- Modify       :
--=======================================================================

if not SceneMgr._SceneBase then
	SceneMgr._SceneBase = {}
end

local SceneBase = SceneMgr._SceneBase

function SceneBase:Init(szName, ccSceneObj)
	self.szSceneName = szName
	self.ccSceneObj = ccSceneObj
end

function SceneBase:Create()
	cclog("Scene [%s] Create Error!", self:GetName())
end

function SceneBase:RemoveSprite(pSprite)
	cclog("Scene [%s]  RemoveSprite Failed!", self:GetName())
end

function SceneBase:GetClassName()
	return self.szClassName
end

function SceneBase:GetName()
	return self.szSceneName
end

function SceneBase:GetCCObj()
	return self.ccSceneObj
end