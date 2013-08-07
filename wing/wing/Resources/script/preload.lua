--===================================================
-- File Name    : preload.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-08-07 13:07:04
-- Description  :
-- Modify       :
--===================================================

if not _G.Def then
	_G.Def = {}
end

if not _G.Maze then
	_G.Maze = {}
end

if not _G.Player then
	_G.Player = {}
end

if not _G.Hero then
	_G.Hero = {}
end

if not _G.Lib then
	_G.Lib = {}
end

require("define")
require("lib")
require("maze")
require("player")
require("hero")