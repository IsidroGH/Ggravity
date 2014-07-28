--
-- level10.lua
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
local xScreens=1
local yScreens=1
local totalTime=120
local totalBalls=15
local goalBalls=10
local basketX=300
local basketY=270
local level=10

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
	physics.addBody( ground1, "static",{ density=1.0, bounce=0, friction=0.5, shape=groundShape } )
	
	middleGroup:insert(ground1)
end

local function createBackground()
	local background1 = display.newImageRect( "backparis.png", 480, 320 )
	background1:setReferencePoint( display.CenterLeftReferencePoint )
	background1.x = 0; background1.y = 160
	
	backGroup:insert( background1 )
	
	objects.createBigStone(322,235,{ density=100.0, friction=0.5, bounce=0.0  },middleGroup,"static")
end


-- Inserta los objetos
local function createObjects()

		
	local stoneB1 = objects.createBigStone(110,-30,{ density=100.0, friction=0.5, bounce=0.0  },middleGroup)
	game.setDragable(stoneB1)
	
	local stoneB2 = objects.createBigStone(130,-30,{ density=100.0, friction=0.5, bounce=0.0  },middleGroup)
	game.setDragable(stoneB2)
	
	local stoneB3 = objects.createBigStone(140,-30,{ density=100.0, friction=0.5, bounce=0.0  },middleGroup)
	game.setDragable(stoneB3)
	
	local stoneB4 = objects.createBigStone(180,-30,{ density=100.0, friction=0.5, bounce=0.0  },middleGroup)
	game.setDragable(stoneB4)
	
	local bamboo1 = objects.createBamboo(220,-78,{ density=40, friction=0.9, bounce=0.0  }, middleGroup)
	game.setDragable(bamboo1)
	
	local bamboo2 = objects.createBamboo(180,-78,{ density=40, friction=0.9, bounce=0.0  }, middleGroup)
	game.setDragable(bamboo2)
	
	local bamboo3 = objects.createBamboo(120,-78,{ density=40, friction=0.9, bounce=0.0  }, middleGroup)
	game.setDragable(bamboo3)

	--local bamboo4 = objects.createBamboo(420,-78,{ density=40, friction=0.9, bounce=0.0  }, middleGroup)
	--game.setDragable(bamboo4)
	
	--local bamboo5 = objects.createBamboo(320,-78,{ density=40, friction=0.9, bounce=0.0  }, middleGroup)
	--game.setDragable(bamboo5)

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

