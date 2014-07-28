--
-- level16.lua
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
local totalTime=240
local totalBalls=30
local goalBalls=10
local level=16

local offset = 350

local basketX=365+offset
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
	
	local ground2 = display.newImageRect( "ground.png", 480, 76 )
	ground2:setReferencePoint( display.BottomLeftReferencePoint )
	ground2.x = 480; ground2.y = 320
	
	local groundShape = { -240,-18, 240,-18, 240,18, -240,18 }
	physics.addBody( ground1, "static",{ density=10000.0, bounce=0.3, friction=0.5, shape=groundShape } )
	physics.addBody( ground2, "static",{ density=10000.0, bounce=0.3, friction=0.5, shape=groundShape } )
	
	middleGroup:insert(ground1)
	middleGroup:insert(ground2)
	
	local stone1 = objects.createBigStone(320+offset,204,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static")
	stone1.rotation=270
		
	local stone2 = objects.createBigStone(355+offset,140,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static")
	stone2.rotation=270
		
	local stone3 = objects.createBigStone(309+offset,156,{ density=4.0, friction=0.1, bounce=0.2  },middleGroup,"nin")
	game.setNonInteractable(stone3)
	
	local stone4 = objects.createBigStone(offset-15,90,{ density=4.0, friction=0.1, bounce=0.2  },middleGroup,"static")
		
	local stone5 = objects.createSrqStone(54+offset,144,{ density=10.0, friction=0.1, bounce=0.0  },middleGroup,"static")
		
	local stone6 = objects.createBigStone(423+offset,230,{ density=4.0, friction=0.1, bounce=0.2  },middleGroup, "static")
		
	local bamboo1 = objects.createBamboo(108+offset,123,{ density=1, friction=0.5, bounce=0.1  }, middleGroup,"static")
	local bamboo2 = objects.createBamboo(244+offset,123,{ density=1, friction=0.5, bounce=0.1  }, middleGroup,"nin")
	bamboo1.linearDamping = 0.7	
	bamboo2.linearDamping = 0.7
	local joint = physics.newJoint( "pivot", bamboo1, bamboo2, 176+offset, 123 )
	joint.isLimitEnabled = true
	joint:setRotationLimits( -45, 45 )
	--game.setNonInteractable(bamboo1)
	game.setNonInteractable(bamboo2)

end

local function createBackground()
	local backBox = display.newRect( 0, 0, 480, 160 )	
	backBox:setFillColor( 88, 186, 239 )
	levelGroup:insert(backBox)
	backBox:toBack()	
	local groundBox = display.newRect( 0, 160, 480, 160 )	
	groundBox:setFillColor( 64, 45, 19 )
	levelGroup:insert(groundBox)
	groundBox:toBack()
	
	local background1 = display.newImageRect( "backmadrid.png", 480, 320 )
	background1:setReferencePoint( display.CenterLeftReferencePoint )
	background1.x = 0; background1.y = 160
	
	local background2 = display.newImageRect( "backmadrid2.png", 480, 320 )
	background2:setReferencePoint( display.CenterLeftReferencePoint )
	background2.x = 480; background2.y = 160
		
	backGroup:insert( background1 )
	backGroup:insert( background2 )
end


-- Inserta los objetos
local function createObjects()
		

	local tube = objects.createTube(200,-60,60, frontGroup)
	game.setDragable(tube)
	
	local stone1 = objects.createBigStone(250,-70,{ density=100.0, friction=0.5, bounce=0  },middleGroup)
	game.setDragable(stone1)
	
	local stone3 = objects.createSmallStone(40,-90,{ density=100.0, friction=1, bounce=0.0  },middleGroup)
	game.setDragable(stone3)
	
	local bamboo3 = objects.createBamboo(150,-100,{ density=20, friction=0.5, bounce=0  }, middleGroup)
	game.setDragable(bamboo3)
	
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


