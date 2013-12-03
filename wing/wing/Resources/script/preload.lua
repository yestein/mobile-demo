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

if not _G.Event then
	_G.Event = {}
end

if not _G.GameMgr then
	_G.GameMgr = {}
end

if not _G.Maze then
	_G.Maze = {}
end

if not _G.Player then
	_G.Player = {}
end

if not _G.Character then
	_G.Character = {}
end

if not _G.Lib then
	_G.Lib = {}
end

if not _G.Hero then
	_G.Hero = {}
end

if not _G.Monster then
	_G.Monster = {}
end

if not _G.Bullet then
	_G.Bullet = {}
end

if not _G.Algorithm then
	_G.Algorithm = {}
end

if not _G.MenuMgr then
	_G.MenuMgr = {}
end

if not _G.SceneMgr then
	_G.SceneMgr = {}
end

require("define")
require("lib")
require("event")
require("game_mgr")
require("maze")
require("player")
require("character")
require("hero")
require("monster")
require("bullet")
require("findpath")
require("menu")
require("scene_mgr")
require("title")
require("scene_base")
require("game_scene")
require("character_mgr")
