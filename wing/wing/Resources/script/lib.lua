--===================================================
-- File Name    : lib.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-08-07 13:10:13
-- Description  :
-- Modify       :
--===================================================

local MetaTable = {
	__index = function(table, key)
		local v = rawget(table, key)
		if v then
			return v
		end
		local tbBase = rawget(table, "_tbBase")
		return tbBase[key]
	end
}

function Lib:NewClass(tbBase)
	local tbNew = { _tbBase = tbBase }
	setmetatable(tbNew, MetaTable)
	return tbNew
end

function Lib:ShowTB1(tb)
	for k, v in pairs(tb) do
		print(string.format("[%s] = %s", tostring(k), tostring(v)))
	end
end

function Lib:CopyTB1(tb)
	local tbRet = {}
	for k, v in pairs(tb) do
		tbRet[k] = v
	end
	return tbRet
end

function Lib:MergeTable(tbDest, tbSrc)
	for _, v in ipairs(tbSrc) do
		tbDest[#tbDest + 1] = v
	end
end

function Lib:ShowTBN(tb, n)

	local function showTB(tbValue, nDeepth, nMaxDeep)
		if nDeepth > n or nDeepth > 4 then
			return
		end
		local szBlank = ""
		for i = 1, nDeepth - 1 do
			szBlank = szBlank .. "\t"
		end
		for k, v in pairs(tbValue) do
			if type(v) ~= "table" then
				print(string.format("%s[%s] = %s", szBlank, tostring(k), tostring(v)))
			else
				print(string.format("%s[%s] = ", szBlank, tostring(k)))
				showTB(v, nDeepth + 1)
			end
		end
	end
	showTB(tb, 1)
end

function Lib:Reload()
	print("Lib:Reload")
	dofile("script/maze.lua")
	dofile("script/lib.lua")
	dofile("script/define.lua")
	dofile("script/hero.lua")
end

function Lib:GetRowColByPos(nX, nY)
	local tbSize = Maze:GetSize()
	local nLogicX = math.floor(nX / Def.BLOCK_WIDTH)
	local nLogicY = math.floor(nY / Def.BLOCK_HEIGHT)

	local nCol = nLogicX + Def.MAZE_COL_COUNT / 2 + 1
	local nRow = nLogicY + math.floor(tbSize.height / Def.BLOCK_HEIGHT / 2) + 1
	return nRow, nCol
end

function Lib:GetPositionByRowCol(nRow, nCol)
	local tbSize = Maze:GetSize()
	local nX = (nCol - Def.MAZE_COL_COUNT / 2 - 0.5) * Def.BLOCK_WIDTH
	local nY = (nRow - math.floor(tbSize.height / Def.BLOCK_HEIGHT / 2) - 0.5) * Def.BLOCK_HEIGHT
	
	return nX, nY
end

function Lib:IsHero(dwId)
	if dwId <= 100 then
		return 1
	else
		return 0
	end
end

