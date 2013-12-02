--=======================================================================
-- File Name    : menu.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-11-28 20:57:43
-- Description  :
-- Modify       :
--=======================================================================

function MenuMgr:Init()
	self.tbMenu = {}
end

function MenuMgr:Uninit()
	self.tbMenu = {}
end

function MenuMgr:CreateMenu(szName)
	if self.tbMenu[szName] then
		cclog("CreateMenu[%s] Failed Already Exists", szName)
		return nil
	end

	local layerMenu = CCLayer:create()   

	self.tbMenu[szName] ={ ccmenuObj = layerMenu, }

    return layerMenu
end

function MenuMgr:AddElement(szName, tbElementList)
	local tbMenu = self:GetMenu(szName)
	if not tbMenu then
		cclog("CreateMenu[%s] is not Exists", szName)
		return 0
	end
	
	local menuArray = CCArray:create()
	local layerMenu = tbMenu.ccmenuObj
	if layerMenu:getChildByTag(1) then
		layerMenu:removeChildByTag(1, true)
	end

	local tbVisibleSize = CCDirector:sharedDirector():getVisibleSize()
	local nCount = 0
	for nIndex = #tbElementList, 1, -1 do
		nCount = nCount + 1
		local tbElement = tbElementList[nIndex]
		local menu = CCMenuItemImage:create(tbElement.szNormalImg, tbElement.szPressedImg)
		menu:registerScriptTapHandler(tbElement.fnCallBack) 
		local itemWidth = menu:getContentSize().width
    	local itemHeight = menu:getContentSize().height
    	menu:setPosition(tbVisibleSize.width - itemWidth / 2, itemHeight * (nCount * 2 - 1) / 2)
    	menuArray:addObject(menu)
	end
	local menuTools = CCMenu:createWithArray(menuArray)
    menuTools:setPosition(0, 0)
    layerMenu:addChild(menuTools, 1, 1)

    return 1
end

function MenuMgr:GetMenu(szName)
	return self.tbMenu[szName]
end
