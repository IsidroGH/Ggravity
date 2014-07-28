--
-- level13.lua
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
local totalTime=240
local totalBalls=20
local goalBalls=10
local level=13

local basketX=80
local basketY=315

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
	
	local groundShape = { -240,-18, 240,-18, 240,18, -240,18 }
	physics.addBody( ground1, "static",{ density=10000.0, bounce=0.3, friction=0.5, shape=groundShape } )
	
	middleGroup:insert(ground1)
	
	local stone0 = objects.createBigStone(68-57,156,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static"); 	stone0.rotation=270
    local stone1 = objects.createBigStone(68,156,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static"); 	stone1.rotation=270
	local stone2 = objects.createBigStone(68+57*1,156,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static"); stone2.rotation=270
	local stone3 = objects.createBigStone(68+57*2,156,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static"); stone3.rotation=270
	local stone4 = objects.createBigStone(68+57*3,156,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static"); stone4.rotation=270
	local stone5 = objects.createBigStone(68+57*4,156,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static"); stone5.rotation=270
	local stone6 = objects.createBigStone(68+57*5,156,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static"); stone6.rotation=270
	local stone7 = objects.createBigStone(68+57*6,156,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static"); stone7.rotation=270
	
	objects.createBigStone(480,110-60*1,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static");
	objects.createBigStone(480,110,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static");
	objects.createBigStone(480,110+60*1,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static");
	objects.createBigStone(480,110+60*2,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static");
	
	objects.createBigStone(400,45,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static");
	objects.createSrqStone(424,125,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static");
	
	local stone = objects.createBigStone(80,90,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static"); stone.rotation=100
	stone = objects.createBigStone(140,100,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static"); stone.rotation=100
end

local function createBackground()
	local background1 = display.newImageRect( "backrio.png", 480, 320 )
	background1:setReferencePoint( display.CenterLeftReferencePoint )
	background1.x = 0; background1.y = 160
		
	backGroup:insert( background1 )
end


-- Inserta los objetos
local function createObjects()
	local tube = objects.createTube(100,-60,60, frontGroup)
	game.setDragable(tube)
	
	local tube = objects.createTube(300,-90,60, frontGroup)
	game.setDragable(tube)

	
	local stone1 = objects.createSmallStone(250,-70,{ density=100.0, friction=0.5, bounce=0  },middleGroup)
	game.setDragable(stone1)

	local stone2 = objects.createSmallStone(250,-50,{ density=100.0, friction=0.5, bounce=0  },middleGroup)
	game.setDragable(stone2)
	
	local stone3 = objects.createSmallStone(250,-20,{ density=100.0, friction=0.5, bounce=0  },middleGroup)
	game.setDragable(stone3)
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


