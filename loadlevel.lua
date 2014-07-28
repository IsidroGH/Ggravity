--
-- loadlevel.lua
-- Copyright (C) 2012 - 2012 Isidro García Hernández
-- isidrogarciahernandez@gmail.com
-- http://javaweirdworld.blogspot.com.es
--
-- This file is part of Ggravity (http://sites.google.com/site/ggravitysoft).
-- 
-- Ggravity is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- Ggravity is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--

module(..., package.seeall)

local game = require( "ggravity" )

---------------------------------------------------------------
-- GROUPS
---------------------------------------------------------------

local localGroup = display.newGroup()
local shadeRect

---------------------------------------------------------------
-- INIT VARS
---------------------------------------------------------------

local function initVars ()

	shadeRect = display.newRect( 0, 0, 480, 320 )
	shadeRect:setFillColor( 0, 0, 0, 255 )
	
	localGroup:insert(shadeRect)
end

---------------------------------------------------------------
-- CLEAN
---------------------------------------------------------------

function clean ( event )
	
end

---------------------------------------------------------------
-- NEW
---------------------------------------------------------------

function new()
	
	-----------------------------------
	-- Initiate variables
	-----------------------------------
	
	initVars()
	
	-----------------------------------
	-- MUST return a display.newGroup()
	-----------------------------------
	
	timer.performWithDelay( 1000, function() director:changeScene(game.currentLevel,"crossfade");end , 1)
	
	return localGroup
	
end
