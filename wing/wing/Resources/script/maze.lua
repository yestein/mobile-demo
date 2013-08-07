--===================================================
-- File Name    : maze.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-08-07 13:06:47
-- Description  :
-- Modify       :
--===================================================

local MAP_FREE = 0
local MAP_BLOCK = 1

function Maze:Save()
    local szPath = CCFileUtils:sharedFileUtils():getWritablePath()
	local file = assert(io.open(szPath.."savemap.txt", "w"))
	for i = 1, 10 do
		local n = math.random(100)
		print("save "..n)
		file:write(tostring(n))
	end
	file:close()
end

function Maze:Load()
	local szPath = CCFileUtils:sharedFileUtils():getWritablePath()
	local file = assert(io.open(szPath.."savemap.txt", "r"))
	local t = file:read("*all")
	print("load "..t)
	file:close()
end

function Maze:RandomMaze()
end

function Maze:Init(nWidth, nHeight)
	self.tbData = {}
	for i = 1, nWidth do
		for j = 1, nHeight do
			self.tbData[i][j] = MAP_BLOCK
		end
	end
end

