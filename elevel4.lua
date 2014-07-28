--
-- elevel4.lua
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
local objects = require( "objects" )
local physics

-- Carasteriticas del nivel
local xScreens=1
local yScreens=1
local totalTime=300
local totalBalls=30
local goalBalls=10
local level=4
local basketX=400
local basketY=325


-- Grupos
local middleGroup = display.newGroup()
local frontGroup = display.newGroup()
local levelGroup = display.newGroup()
local backGroup = display.newGroup()
local uiGroup = display.newGroup()
local popupGroup = display.newGroup()
local scenario = display.newGroup()

-- Fondo
local clouds1
local clouds2
local clouds3
local clouds4

-- Suelo
local function createGround()
	local ground1 = display.newImageRect( "ground.png", 480, 76 )
	ground1:setReferencePoint( display.BottomLeftReferencePoint )
	ground1.x = 0; ground1.y = 320
	
	--local ground2 = display.newImageRect( "ground.png", 480, 76 )
	--ground2:setReferencePoint( display.BottomLeftReferencePoint )
	--ground2.x = 480; ground2.y = 320
	
	local groundShape = { -240,-18, 240,-18, 240,18, -240,18 }
	physics.addBody( ground1, "static",{ density=10000.0, bounce=0.3, friction=0.5, shape=groundShape } )
	--physics.addBody( ground2, "static",{ density=10000.0, bounce=0.3, friction=0.5, shape=groundShape } )
	
	middleGroup:insert(ground1)
	--middleGroup:insert(ground2)
	
	local stone
	
	stone = objects.createBigStone(40,90,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static")
	stone.rotation=140
	stone = objects.createBigStone(80,140,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static")
	stone.rotation=140
	stone = objects.createBigStone(120,190,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static")
	stone.rotation=140
	stone = objects.createBigStone(160,240,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static")
	stone.rotation=140

end

local function createBackground()
	local background1 = display.newImageRect( "extraback1.png", 480, 320 )
	background1:setReferencePoint( display.CenterLeftReferencePoint )
	background1.x = 0; background1.y = 160
	
	--local background2 = display.newImageRect( "fondo1.png", 480, 320 )
	--background2:setReferencePoint( display.CenterLeftReferencePoint )
	--background2.x = 480; background2.y = 160
		
	backGroup:insert( background1 )
	--backGroup:insert( background2 )
end


-- Inserta los objetos
local function createObjects()
	local obj
	
	obj = objects.createBamboo(150,-30,{ density=50, friction=0.5, bounce=0.0  }, middleGroup)
	game.setDragable(obj)
	
	obj = objects.createBamboo(350,-30,{ density=50, friction=0.5, bounce=0.0  }, middleGroup)
	game.setDragable(obj)	
end

function gameLoop()
			if (game.playing) then 
				-- Control de tiempo
				game.controlTime()
			end
end


local function initLevel()
	createBackground()
	createGround()
	createObjects()
	game.reorder()
	Runtime:addEventListener( "enterFrame", gameLoop )
end


function new()	
	game.newLevel(levelGroup, backGroup, middleGroup, frontGroup, uiGroup, popupGroup, scenario, xScreens,yScreens,totalTime,totalBalls,goalBalls,level,basketX,basketY)	
	physics = game.physics
	initLevel()			
	
	return levelGroup	
end


function clean()	
	Runtime:removeEventListener( "enterFrame", gameLoop )
	game.clean()
end


