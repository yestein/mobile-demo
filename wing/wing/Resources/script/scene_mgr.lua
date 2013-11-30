--=======================================================================
-- File Name    : scene_mgr.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-11-28 20:57:43
-- Description  :
-- Modify       :
--=======================================================================
require("scene_base")

if not SceneMgr.tbSceneClass then
    SceneMgr.tbSceneClass = {}
end

function SceneMgr:Init()
	self.tbScene = {}
end

function SceneMgr:Uninit()
	self.tbScene = {}
end

function SceneMgr:GetScene(szName)
	return self.tbScene[szName]
end

function SceneMgr:GetSceneObj(szName)
    local tbScene = self:GetScene(szName)
    if tbScene then
        return tbScene:GetCCObj()
    end
end

function SceneMgr:GetClass(szClassName, bCreate)
    if not SceneMgr.tbSceneClass[szClassName] and bCreate then
        local tbClass = Lib:NewClass(self._SceneBase)
        tbClass.szClassName = szClassName
        SceneMgr.tbSceneClass[szClassName] = tbClass
    end
    return SceneMgr.tbSceneClass[szClassName]    
end

function SceneMgr:CreateScene(szName, szClassName)
	if self.tbScene[szName] then
		cclog("Create Scene [%s] Failed! Already Exists", szName)
		return
	end
    if not szClassName then
        szClassName = szName
    end
     local tbClass = SceneMgr:GetClass(szClassName)
    if not tbClass then
        return cclog("Error! No Scene Class [%s] !", szClassName)
    end

	local ccSceneObj = CCScene:create()   
	local tbScene = Lib:NewClass(tbClass)
    tbScene:Init(szName, ccSceneObj)
    self.tbScene[szName] = tbScene
	return tbScene
end