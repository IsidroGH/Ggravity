--
-- reload.lua
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

local localGroup = display.newGroup()


---------------------------------------------------------------
-- INIT VARS
---------------------------------------------------------------

local function initVars ()
	local back = display.newRect( 0, 0, 480, 320 )	
	back:setFillColor( 16, 37, 63 )
	localGroup:insert(back)
	
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
	
	timer.performWithDelay(1000,function()director:changeScene("settings","crossfade");end,1)
		
	return localGroup
	
end
