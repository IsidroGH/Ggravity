--
-- level4.lua
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
local totalTime=100
local totalBalls=10
local goalBalls=5

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
	
	local stone1 = objects.createBigStone(240,235,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static")
	local stone2 = objects.createBigStone(240,235-58,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static")
end

local function createBackground()
	local background1 = display.newImageRect( "backny.png", 480, 320 )
	background1:setReferencePoint( display.CenterLeftReferencePoint )
	background1.x = 0; background1.y = 160
		
	backGroup:insert( background1 )
end


-- Inserta los objetos
local function createObjects()
	
	local stone1 = objects.createSmallStone(350,-80,{ density=100.0, friction=0.5, bounce=0.0  },middleGroup)
	game.setDragable(stone1)
		
	local elastic = objects.createElastic(150,-30,1.0, middleGroup)
	game.setDragable(elastic)
	
	local bamboo1 = objects.createBamboo(300,-100,{ density=2.5, friction=0.5, bounce=0.1  }, middleGroup)
	game.setDragable(bamboo1)

	local stone1 = objects.createSrqStone(30,-50,{ density=100.0, friction=0.5, bounce=0.0  },middleGroup)
	game.setDragable(stone1)
	
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
	-- Tiempo consumido menos de 30 segundos y todas las manzanas metidas
	if params[1]<=30 and params[2]==totalBalls then
		game.unlockAchievement(OF_L4_AllBalls30SecsId)
	end
end

function new()	
	game.newLevel(levelGroup, backGroup, middleGroup, frontGroup, uiGroup, popupGroup, scenario, xScreens,yScreens,totalTime,totalBalls,goalBalls,4,250,325)	
	game.onEndLevel=onEndLevel
	physics = game.physics
	initLevel()			
	
	return levelGroup	
end


function clean()	
	Runtime:removeEventListener( "enterFrame", gameLoop )
	
	game.clean()
end


