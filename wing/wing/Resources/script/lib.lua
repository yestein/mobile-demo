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

