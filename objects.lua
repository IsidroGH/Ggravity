--
-- objects.lua
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

local boingSound = audio.loadSound( "elastic.wav" )
local explosionSound = audio.loadSound( "explosion.wav" )

function createBamboo(x,y, properties, group, mode)
	if not mode then mode="dynamic"; end

	local bamboo 

	if mode=="nin" then
		bamboo = display.newImageRect( "rampni.png", 136, 11 )
	else
		bamboo = display.newImageRect( "ramp.png", 136, 11 )
	end
	
	bamboo.x=x; bamboo.y=y
	physics.addBody( bamboo, mode, properties )
	bamboo.mode=mode
	group:insert(bamboo)
	return bamboo
end


function createSrqStone(x,y, properties, group, mode)
	if not mode then mode="dynamic"; end
	
	local stone
	
	if mode=="static" then
		stone = display.newImageRect( "sqrstonefixed.png",30 , 30 )
	elseif mode=="nin" then
		stone = display.newImageRect( "sqrstoneni.png",30 , 30 )
	else
		stone = display.newImageRect( "sqrstone.png",30 , 30 )
	end
	stone.x=x; stone.y=y
	physics.addBody( stone, mode, properties )
	group:insert(stone)
	stone.mode=mode
	return stone
end

function createBigStone(x,y, properties, group, mode)
	if not mode then mode="dynamic"; end
	
	local stone
	
	if mode=="static" then
		stone = display.newImageRect( "bigstonefixed.png",30 , 60 )
	elseif mode=="nin" then
		stone = display.newImageRect( "bigstoneni.png",30 , 60 )
	else
		stone = display.newImageRect( "bigstone.png",30 , 60 )
	end
	
	stone.x=x; stone.y=y
	physics.addBody( stone, mode, properties )
	group:insert(stone)
	stone.mode=mode
	return stone
end

function createSharpStone(x,y, properties, group, mode)
	if not mode then mode="dynamic"; end
	
	local stone
	
	if mode=="static" then
		stone = display.newImageRect( "sharpstonefixed.png",10 , 60 )
	else
		stone = display.newImageRect( "sharpstonefixed.png",10 , 60 )
	end
	stone.x=x; stone.y=y
	physics.addBody( stone, mode, properties )
	group:insert(stone)
	stone.mode=mode
	return stone
end

function createSmallStone(x,y, properties, group, mode)	
	if not mode then mode="dynamic"; end
	
	local stone
	
	if mode=="static" then
		stone = display.newImageRect( "smallstonefixed.png",30 , 12 )
	else
		stone = display.newImageRect( "smallstone.png",30 , 12 )
	end
		
	stone.x=x; stone.y=y
	physics.addBody( stone, mode, properties )
	group:insert(stone)
	stone.mode=mode
	return stone
end

function createElastic(x,y, bounce, group, mode)	
	if not mode then mode="dynamic"; end
	
	local elasticBaseShape = {-40,17,-40,10,40,10,40,17}
	local elasticLeftShape = {-40,10,-40,-17,-30,-17,-30,10}
	local elasticRightShape = {30,10,30,-17,40,-17,40,10}
	local elasticShape = {-25,0,-25,-15,25,-15,25,0}
	local elastic = managedObjects.newObject( { "elastic0.png","elastic1.png","elastic2.png" }, 80, 34, x, y, {0.05}, false, 1, group,0.4 )
	elastic.name="Elastic"
	
	local function onElasticCollision (self, part)
		if part==4 then
			self:stopAnimation()
			self:startAnimation()
			return boingSound
		end
	end
	
	elastic.onCollision = onElasticCollision
	
	physics.addBody( elastic, mode, 
			{ density=100, friction=1, bounce=0.05, shape = elasticBaseShape }, 
			{ density=100, friction=1, bounce=0.05, shape = elasticLeftShape }, 
			{ density=100, friction=1, bounce=0.05, shape = elasticRightShape},
			{ density=10, friction=0.5, bounce=bounce, shape = elasticShape} 
	)
	group:insert(elastic)
	elastic.mode=mode
	return elastic
end

function createTube(x,y,power,group, mode)	
	
	if not mode then mode="dynamic"; end
	
	local tubeBase =   {-40, 18, -40,  14, 40,  14, 40, 18}
	local tubeTop =    {-40,-14, -40, -18, 40, -18, 40,-14}
	local tubeSensor = {-30, 10, -30, -10, 14, -10, 14, 10}

	local tube = display.newImageRect("tube.png",80,36 )
	tube.x=x;tube.y=y
	
	local function onTubeSensor (self, part, other)
		if part==3 and other.name=="Ball" then
			other:setLinearVelocity( 0, 0 )
			other.angularVelocity = 0
			
			local fx = power
			local fy = 0
			local angle = (self.rotation*math.pi)/180
			local fxp = fx*math.cos(angle)-fy*math.sin(angle)
			local fyp = fx*math.sin(angle)+fy*math.cos(angle)
		
			other.isBullet=true
			other:applyLinearImpulse( fxp, fyp, other.x, other.y )
			--game.displayPoof(self.x-60,self.y,group)
			
			local px = -60*math.cos(angle)
			local py = -60*math.sin(angle)
			game.displayPoof(self.x+px,self.y+py,group)
			return explosionSound
		end
	end
	
	tube.onCollision = onTubeSensor

	physics.addBody( tube, mode, 
			{ density=100, friction=1, bounce=0, shape = tubeBase },
			{ density=100, friction=1, bounce=0, shape = tubeTop },
			{ isSensor=true, shape=tubeSensor }
	)
	
	group:insert(tube)
	tube.mode=mode
	
	tube.name="tube"
	tube.power=power
	
	return tube
end



