--
-- level1.lua
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
local utils = require( "utils" )

local physics

-- Carasteriticas del nivel
local xScreens=1
local yScreens=1
local totalTime=50
local totalBalls=7
local goalBalls=5

-- Grupos
local middleGroup = display.newGroup()
local frontGroup = display.newGroup()
local levelGroup = display.newGroup()
local backGroup = display.newGroup()
local uiGroup = display.newGroup()
local popupGroup = display.newGroup()
local scenario = display.newGroup()
local tutorialGroup = display.newGroup()

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
	
	local stone1 = objects.createBigStone(70,250,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static")
	stone1.rotation=270
	local stone2 = objects.createBigStone(70+59,250,{ density=100.0, friction=0.5, bounce=0.2  },middleGroup,"static")
	stone2.rotation=270
end

local function createBackground()
	local background1 = display.newImageRect( "backny.png", 480, 320 )
	background1:setReferencePoint( display.CenterLeftReferencePoint )
	background1.x = 0; background1.y = 160
		
	backGroup:insert( background1 )
end


-- Inserta los objetos
local function createObjects()
	
	local stone1 = objects.createSmallStone(250,-80,{ density=100.0, friction=0.5, bounce=0.0  },middleGroup)
	game.setDragable(stone1)
		
	local bamboo1 = objects.createBamboo(350,-30,{ density=50, friction=0.5, bounce=0.0  }, middleGroup)
	game.setDragable(bamboo1)	
end

local function createTutorial()
	local finger = display.newImageRect( "touchme.png", 70, 99 )
	finger.x=115;finger.y=55
	finger.rotation=-45
	tutorialGroup:insert(finger)
	tutorialGroup.alpha=0		
	
	local style = utils.getDefaultButtonStyle()
	style.textSize=30
	
	local fingerText = utils.createMessage(msgs.get(72),style,tutorialGroup,display.TopLeftReferencePoint,150,90)
	
	frontGroup:insert(tutorialGroup)
	
	transition.to( tutorialGroup, { time=1000, alpha=1} )
	game.onCreateNextBall=nil	
end

local function removeTutorial()
	tutorialGroup:removeSelf()
	tutorialGroup=nil
	game.onThrowBall=nil
	game.onGameOver=nil
	game.onCreateNextBall=nil
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
	game.newLevel(levelGroup, backGroup, middleGroup, frontGroup, uiGroup, popupGroup, scenario, xScreens,yScreens,totalTime,totalBalls,goalBalls,1,165,325)	
	
	game.onCreateNextBall=createTutorial
	game.onGameOver=removeTutorial
	game.onThrowBall=removeTutorial
	
	physics = game.physics
	initLevel()			
	
	return levelGroup	
end


function clean()	
	Runtime:removeEventListener( "enterFrame", gameLoop )
	game.clean()
end


