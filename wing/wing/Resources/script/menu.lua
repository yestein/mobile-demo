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

function MenuMgr:UpdateByString(szName, tbElementList, tbParam)
	local szFontName = tbParam.szFontName or ""
	local nSize = tbParam.nSize or 16
	local szAlignType = tbParam.szAlignType or "left"
	local nIntervalX = tbParam.nIntervalX or 15
	local nIntervalY = tbParam.nIntervalY or 0

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
	local itemHeight = nil
	local nY = 0
	for nRow, tbRow in ipairs(tbElementList) do
		local nX = 0
		if nRow ~= 1 then
			nY = nY - nIntervalY
		end
		local tbRowMenu = {}
		for nCol, tbElement in ipairs(tbRow) do
			local ccLabel = CCLabelTTF:create(tbElement.szItemName or "错误的菜单项", szFontName, nSize)
			local menu = CCMenuItemLabel:create(ccLabel)
			menu:setAnchorPoint(CCPoint:new(0, 0))
			menu:registerScriptTapHandler(tbElement.fnCallBack)
			local itemWidth = menu:getContentSize().width
			if not itemHeight then
		    	itemHeight = menu:getContentSize().height
		    end

			if szAlignType == "right" then
				if nCol ~= 1 then
					nX = nX - nIntervalX
				end
		    	nX = nX - itemWidth
		    	menu:setPosition(nX, nY -  itemHeight)
		    else
		    	if nCol ~= 1 then
		    		nX = nX + nIntervalX
		    	end
		    	menu:setPosition(nX, nY - itemHeight)
				nX = nX + itemWidth
		    end
		    tbRowMenu[#tbRowMenu + 1] = menu
	    	menuArray:addObject(menu)
	    end
	    if szAlignType == "center" then
	    	local nOffsetX = math.floor(nX / 2)
	    	for _, menu in ipairs(tbRowMenu) do
	    		local nMenuX, nMenuY = menu:getPosition()
	    		menu:setPosition(nMenuX - nOffsetX, nMenuY)
	    	end
		end
		nY = nY - itemHeight
	end
	local menuTools = CCMenu:createWithArray(menuArray)
	if szAlignType == "center" and itemHeight then
		local nOffsetY = math.floor(-nY / 2)
		menuTools:setPosition(0, nOffsetY - itemHeight / 2)
	else
    	menuTools:setPosition(0, 0)
    end
    layerMenu:addChild(menuTools, 1, 1)

    return 1
end

function MenuMgr:GetMenu(szName)
	return self.tbMenu[szName]
end
