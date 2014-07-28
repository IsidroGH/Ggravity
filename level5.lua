--
-- level5.lua
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
local xScreens=2
local yScreens=1
local totalTime=200
local totalBalls=20
local goalBalls=5
local basketX=255
local basketY=325
local level=5

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
	local backBox = display.newRect( 0, 0, 480, 160 )	
	backBox:setFillColor( 172, 220, 247 )
	levelGroup:insert(backBox)
	backBox:toBack()	
	local groundBox = display.newRect( 0, 160, 480, 160 )	
	groundBox:setFillColor( 64, 45, 19 )
	levelGroup:insert(groundBox)
	groundBox:toBack()	
	
	local ground1 = display.newImageRect( "ground.png", 480, 76 )
	ground1:setReferencePoint( display.BottomLeftReferencePoint )
	ground1.x = 0; ground1.y = 320
	
	local ground2 = display.newImageRect( "ground.png", 480, 76 )
	ground2:setReferencePoint( display.BottomLeftReferencePoint )
	ground2.x = 480; ground2.y = 320
	
	local groundShape = { -240,-18, 240,-18, 240,18, -240,18 }
	physics.addBody( ground1, "static",{ density=10000.0, bounce=0.3, friction=0.5, shape=groundShape } )
	physics.addBody( ground2, "static",{ density=10000.0, bounce=0.3, friction=0.5, shape=groundShape } )
	
	middleGroup:insert(ground1)
	middleGroup:insert(ground2)
end

local function createBackground()
	local background1 = display.newImageRect( "backny.png", 480, 320 )
	background1:setReferencePoint( display.CenterLeftReferencePoint )
	background1.x = 0; background1.y = 160
	
	local background2 = display.newImageRect( "backny2.png", 480, 320 )
	background2:setReferencePoint( display.CenterLeftReferencePoint )
	background2.x = 480; background2.y = 160
		
	backGroup:insert( background1 )
	backGroup:insert( background2 )
	
	local stone1 = objects.createBigStone(150+50*0,235,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static")
	local stone2 = objects.createBigStone(150+45*1,235,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static")
	local stone3 = objects.createBigStone(170,250-58,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static")
	stone3.rotation=270
	
	local stone4 = objects.createBigStone(150+45*2,235,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static")
	local stone5 = objects.createBigStone(170+58,250-58,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static")
	stone5.rotation=270
	
	local stone6 = objects.createBigStone(150+105,235-70,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static")
	stone6.rotation=270

end


-- Inserta los objetos
local function createObjects()
	
	local stone1 = objects.createSmallStone(30,-30,{ density=100.0, friction=0.5, bounce=0.0  },middleGroup)
	game.setDragable(stone1)
	
	local stone2 = objects.createSrqStone(350,-20,{ density=100.0, friction=0.5, bounce=0.0  },middleGroup)
	game.setDragable(stone2)
	
	local stone3 = objects.createSmallStone(150,-40,{ density=100.0, friction=0.5, bounce=0.0  },middleGroup)
	game.setDragable(stone3)

	local elastic1 = objects.createElastic(370,-180, 0.8, middleGroup)
	game.setDragable(elastic1)
	
	local elastic2 = objects.createElastic(340,-100, 0.8, middleGroup)
	game.setDragable(elastic2)

	local tube = objects.createTube(250,-100,17,frontGroup)
	game.setDragable(tube)
	
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
	--game.reorder()
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


