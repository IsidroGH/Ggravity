--
-- level20.lua
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
local totalTime=500
local totalBalls=40
local goalBalls=5
local level=20

local offset = 350

local basketX=795
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
	
	local obj
	
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
	
	local obj
	obj = objects.createBigStone(30,160,{ density=100.0, friction=0.5, bounce=0  },middleGroup,"static")
	obj.rotation=270
	
	obj = objects.createBigStone(30+60*1,160,{ density=100.0, friction=0.5, bounce=0 } ,middleGroup,"static")
	obj.rotation=270
	
	obj = objects.createBigStone(30+60*2,160,{ density=100.0, friction=0.5, bounce=0 },middleGroup,"static")
	obj.rotation=270
	
	obj = objects.createBigStone(30+60*3,160,{ density=100.0, friction=0.5, bounce=0 },middleGroup,"static")
	obj.rotation=270
	
	obj = objects.createBigStone(30+60*4,160,{ density=100.0, friction=0.5, bounce=0 } ,middleGroup,"static")
	obj.rotation=270
	
	obj = objects.createBigStone(30+60*5,160,{ density=100.0, friction=0.5, bounce=0 } ,middleGroup,"static")
	obj.rotation=270
	
	--[[
	obj = objects.createBigStone(50,50,{ density=100.0, friction=0.5, bounce=0 } ,middleGroup,"static")
	game.setDragable(obj)


		obj = objects.createBigStone(50,80,{ density=100.0, friction=0.5, bounce=0 } ,middleGroup,"static")
	game.setDragable(obj)
	]]--
	
	
	--objects.createBigStone(370,174,{ density=100.0, friction=0.5, bounce=0 } ,middleGroup,"static")
	objects.createBigStone(440,174,{ density=100.0, friction=0.5, bounce=0 } ,middleGroup,"static")
	--objects.createBigStone(370,174+60,{ density=100.0, friction=0.5, bounce=0 } ,middleGroup,"static")
	objects.createBigStone(440,174+60,{ density=100.0, friction=0.5, bounce=0 } ,middleGroup,"static")
	
	objects.createBigStone(410,60,{ density=100.0, friction=0.5, bounce=0  },middleGroup,"static")
	
	obj = objects.createBigStone(330,83,{ density=100.0, friction=0.5, bounce=0 } ,middleGroup,"static")
	obj.rotation=130
	
	obj = objects.createBigStone(428,130,{ density=100.0, friction=0.5, bounce=0 } ,middleGroup,"static")
	obj.rotation=270
	
	obj = objects.createBigStone(255,114,{ density=2.0, friction=0.15, bounce=0  },middleGroup,"nin")
	game.setNonInteractable(obj)
	
	--
	obj = objects.createBigStone(616,131,{ density=100.0, friction=0.5, bounce=0 } ,middleGroup,"static")
	obj.rotation=270	
	obj = objects.createBigStone(616+60*1,131,{ density=100.0, friction=0.5, bounce=0 } ,middleGroup,"static")
	obj.rotation=270	
	obj = objects.createBigStone(616+60*2,131,{ density=100.0, friction=0.5, bounce=0 } ,middleGroup,"static")
	obj.rotation=270	
	obj = objects.createBigStone(616+60*3,131,{ density=100.0, friction=0.5, bounce=0 } ,middleGroup,"static")
	obj.rotation=270
	obj = objects.createBigStone(616+60*4,131,{ density=100.0, friction=0.5, bounce=0 } ,middleGroup,"static")
	obj.rotation=270
	
	obj = objects.createBigStone(646,240,{ density=100.0, friction=0.5, bounce=0 } ,middleGroup,"static")
	obj.rotation=270
	obj = objects.createBigStone(646+60*1,240,{ density=100.0, friction=0.5, bounce=0 } ,middleGroup,"static")
	obj.rotation=270
	obj = objects.createBigStone(646+60*2,240,{ density=100.0, friction=0.5, bounce=0 } ,middleGroup,"static")
	obj.rotation=270
	obj = objects.createBigStone(646+60*3+40,240,{ density=100.0, friction=0.5, bounce=0 } ,middleGroup,"static")
	obj.rotation=270
	--
	
	obj = objects.createSrqStone(782,210,{ density=100.0, friction=0.5, bounce=0 } ,middleGroup,"static")
	--game.setDragable(obj)		
	
end


-- Inserta los objetos
local function createObjects()
	local obj
	
	obj = objects.createTube(400,-80,20, frontGroup)
	game.setDragable(obj)
	
	obj = objects.createTube(490,-20,20, frontGroup)
	game.setDragable(obj)
	
	obj = objects.createSmallStone(70,-120,{ density=100.0, friction=1, bounce=0.0  },middleGroup)
	game.setDragable(obj)
	
	obj = objects.createSmallStone(100,-130,{ density=100.0, friction=1, bounce=0.0  },middleGroup)
	game.setDragable(obj)
	
	obj = objects.createSmallStone(120,-140,{ density=100.0, friction=1, bounce=0.0  },middleGroup)
	game.setDragable(obj)
	
	obj = objects.createSmallStone(150,-90,{ density=100.0, friction=1, bounce=0.0  },middleGroup)
	game.setDragable(obj)
	
	obj = objects.createElastic(80,-100, 0.6, middleGroup)
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

local onEndLevel = function (params)
	-- 35 manzanas metidas
	if params[2]>=35 then
		game.unlockAchievement(OF_L20_35BallsAchievementId)
	end
end

function new()	
	game.newLevel(levelGroup, backGroup, middleGroup, frontGroup, uiGroup, popupGroup, scenario, xScreens,yScreens,totalTime,totalBalls,goalBalls,level,basketX,basketY)	
	game.onEndLevel=onEndLevel
	physics = game.physics
	initLevel()			
	
	return levelGroup	
end


function clean()	
	Runtime:removeEventListener( "enterFrame", gameLoop )
	
	game.clean()
end


