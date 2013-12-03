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

function MenuMgr:UpdateBySprite(szName, tbElementList)
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
	for nRow, tbRow in ipairs(tbElementList) do
		local nX = 0
		for nCol, tbElement in ipairs(tbRow) do
			print(tbElement.szImage)
			local texture = CCTextureCache:sharedTextureCache():addImage(tbElement.szImage)
			local rectNormal = CCRectMake(unpack(tbElement.tbRect["normal"]))
			local frameNormal = CCSpriteFrame:createWithTexture(texture, rectNormal)
			local spriteNormal = CCSprite:createWithSpriteFrame(frameNormal)

			local rectSelected = CCRectMake(unpack(tbElement.tbRect["selected"]))
			local frameSelected = CCSpriteFrame:createWithTexture(texture, rectSelected)
			local spriteSelected = CCSprite:createWithSpriteFrame(frameSelected)
			local menu = CCMenuItemSprite:create(spriteNormal, spriteSelected)
			menu:setAnchorPoint(CCPoint:new(0, 0))
			menu:registerScriptTapHandler(tbElement.fnCallBack)
			local itemWidth = menu:getContentSize().width
	    	local itemHeight = menu:getContentSize().height
	    	nX = nX - itemWidth - 15
	    	menu:setPosition(nX,  -nRow * itemHeight)
	    	menuArray:addObject(menu)
	    end
	end
	local menuTools = CCMenu:createWithArray(menuArray)
    menuTools:setPosition(0, 0)
    layerMenu:addChild(menuTools, 1, 1)
    return 1
end

function MenuMgr:UpdateByImage(szName, tbElementList)
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
	for nRow, tbRow in ipairs(tbElementList) do
		local nX = 0
		for nCol, tbElement in ipairs(tbRow) do
			local menu = CCMenuItemImage:create(tbElement.szNormalImg, tbElement.szPressedImg)
			menu:setAnchorPoint(CCPoint:new(0, 0))
			menu:registerScriptTapHandler(tbElement.fnCallBack)
			local itemWidth = menu:getContentSize().width
	    	local itemHeight = menu:getContentSize().height
	    	nX = nX - itemWidth - 15
	    	menu:setPosition(nX,  -nRow * itemHeight)
	    	menuArray:addObject(menu)
	    end
	end
	local menuTools = CCMenu:createWithArray(menuArray)
    menuTools:setPosition(0, 0)
    layerMenu:addChild(menuTools, 1, 1)

    return 1
end

function MenuMgr:UpdateByString(szName, tbElementList, szFontName, nSize)
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
	for nRow, tbRow in ipairs(tbElementList) do
		local nX = 0
		for nCol, tbElement in ipairs(tbRow) do
			local ccLabel = CCLabelTTF:create(tbElement.szItemName or "错误的菜单项", szFontName or "", nSize or 16)
			local menu = CCMenuItemLabel:create(ccLabel)		
			menu:setAnchorPoint(CCPoint:new(0, 0))
			menu:registerScriptTapHandler(tbElement.fnCallBack)
			local itemWidth = menu:getContentSize().width
	    	local itemHeight = menu:getContentSize().height
	    	nX = nX - itemWidth - 15
	    	menu:setPosition(nX,  -nRow * itemHeight)
	    	menuArray:addObject(menu)
	    end
	end
	local menuTools = CCMenu:createWithArray(menuArray)
    menuTools:setPosition(0, 0)
    layerMenu:addChild(menuTools, 1, 1)

    return 1
end

function MenuMgr:GetMenu(szName)
	return self.tbMenu[szName]
end
