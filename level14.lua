--
-- level14.lua
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

-- Necesita 15 pelotas para romper la barrera

-- Carasteriticas del nivel
local xScreens=2
local yScreens=1
local totalTime=300
local totalBalls=20
local goalBalls=5
local basketX=484
local basketY=210
local level=14

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
	
	local ground2 = display.newImageRect( "ground.png", 480, 76 )
	ground2:setReferencePoint( display.BottomLeftReferencePoint )
	ground2.x = 480; ground2.y = 320
	
	local groundShape = { -240,-18, 240,-18, 240,18, -240,18 }
	physics.addBody( ground1, "static",{ density=1.0, bounce=0, friction=0.5, shape=groundShape } )
	physics.addBody( ground2, "static",{ density=1.0, bounce=0, friction=0.5, shape=groundShape } )
	
	middleGroup:insert(ground1)
	middleGroup:insert(ground2)
end

local function createBackground()
	local backBox = display.newRect( 0, 0, 480, 160 )	
	backBox:setFillColor( 172, 220, 247 )
	levelGroup:insert(backBox)
	backBox:toBack()	
	local groundBox = display.newRect( 0, 160, 480, 160 )	
	groundBox:setFillColor( 64, 45, 19 )
	levelGroup:insert(groundBox)
	groundBox:toBack()
	
	local background1 = display.newImageRect( "backrio.png", 480, 320 )
	background1:setReferencePoint( display.CenterLeftReferencePoint )
	background1.x = 0; background1.y = 160
	
	local background2 = display.newImageRect( "backrio2.png", 480, 320 )
	background2:setReferencePoint( display.CenterLeftReferencePoint )
	background2.x = 480; background2.y = 160
		
	backGroup:insert( background1 )
	backGroup:insert( background2 )

	local pos = 350

	local o1 = objects.createSrqStone(pos-5,248,{ density=100.0, friction=0.5, bounce=0.0  },middleGroup,"static")
	local o2 = objects.createBigStone(pos-5,170,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static")
	local o3 = objects.createBigStone(pos-5,111,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static")
	
	local s1 = objects.createSmallStone(pos-19,67,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static")
	s1.rotation=270
		
	local b1 = objects.createBamboo(pos+60,75,{ density=5, friction=1, bounce=0.0  }, middleGroup,"nin")
	game.setNonInteractable(b1)
	
	local ox=pos+120
	local o4 = objects.createSrqStone(ox,248,{ density=32.0, friction=0.1, bounce=0.0  },middleGroup,"nin")	
	game.setNonInteractable(o4)
	local o5 = objects.createSrqStone(ox,218,{ density=16.0, friction=0.1, bounce=0.0  },middleGroup,"nin")
	game.setNonInteractable(o5)
	local o6 = objects.createSrqStone(ox,188,{ density=8.0, friction=0.1, bounce=0.0  },middleGroup,"nin")
	game.setNonInteractable(o6)
	local o7 = objects.createSrqStone(ox,158,{ density=4.0, friction=0.1, bounce=0.0  },middleGroup,"nin")
	game.setNonInteractable(o7)
	local o8 = objects.createSrqStone(ox,128,{ density=2.0, friction=0.1, bounce=0.0  },middleGroup,"nin")
	game.setNonInteractable(o8)
	local o9 = objects.createSrqStone(ox,98,{ density=1.0, friction=0.1, bounce=0.0  },middleGroup,"nin")
	game.setNonInteractable(o9)
	
	
	local o8 = objects.createSrqStone(ox-45,128,{ density=2.0, friction=0.5, bounce=0.0  },middleGroup,"static")
		
	local t2 = objects.createBigStone(pos+160,65,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static")
	t2.rotation=270
	
	local o11 = objects.createBigStone(pos+190,234,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static")
	local o12 = objects.createBigStone(pos+190,174,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static")
	local o13 = objects.createBigStone(pos+190,111,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static")

end


-- Inserta los objetos
local function createObjects()

	local stone1 = objects.createSrqStone(50,-10,{ density=100.0, friction=0.5, bounce=0.0  },middleGroup)
	game.setDragable(stone1)
	
	local stone2 = objects.createSrqStone(120,-60,{ density=100.0, friction=0.5, bounce=0.0  },middleGroup)
	game.setDragable(stone2)
	
	local stone3 = objects.createSrqStone(150,-160,{ density=100.0, friction=0.5, bounce=0.0  },middleGroup)
	game.setDragable(stone3)
	
	local bamboo1 = objects.createBamboo(150,-80,{ density=100, friction=1, bounce=0.0  }, middleGroup)
	game.setDragable(bamboo1)
	
	local tube = objects.createTube(260,-110,25, frontGroup)
	game.setDragable(tube)
	
	local stone4 = objects.createSmallStone(200,-40,{ density=100.0, friction=1, bounce=0.0  },middleGroup)
	game.setDragable(stone4)

	local stone5 = objects.createSmallStone(100,-40,{ density=100.0, friction=1, bounce=0.0  },middleGroup)
	game.setDragable(stone5)
	
  	local stone6 = objects.createSmallStone(150,-40,{ density=100.0, friction=1, bounce=0.0  },middleGroup)
	game.setDragable(stone6)
	
	local stone7 = objects.createSmallStone(50,-40,{ density=100.0, friction=1, bounce=0.0  },middleGroup)
	game.setDragable(stone7)
	

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
	--physics.start()
	initLevel()			
	
	return levelGroup	
end


function clean()	
	Runtime:removeEventListener( "enterFrame", gameLoop )
	
	game.clean()
end


