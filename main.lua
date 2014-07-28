--
-- main.lua
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

display.setStatusBar( display.HiddenStatusBar )

---------------------------------------------------------------
-- Import director class
---------------------------------------------------------------

director = require "director"
gameNetwork = require "gameNetwork"
local game = require "ggravity"

---
version=1.1
levelsCount=20
freeLevelsCount=5
extraLevelsCount=5
freeMode = false
unlockedMode = true
ggravityLink="http://itunes.apple.com/us/app/ggravity/id445196687"
ggravityFreeLink="http://itunes.apple.com/us/app/ggravity-free/id445209936"
---

if freeMode then
	of_name="Ggravity Free"
	
	-- Ggravity Free
	of_product_key = "YOUR_OF_PK"
	of_product_secret = "YOUR_OF_PS"
	of_app_id = 334083
	
	-- LeaderBoards
	openFeintLeaderboardIds={849676}
	
	-- Achievements
	OF_BlockAchivementIds={1131342}
	OF_L4_AllBalls30SecsId=1131352
else
	of_name="Ggravity"
	-- Ggravity
	of_product_key = "YOUR_OF_PK"
	of_product_secret = "YOUR_OF_PS"
	of_app_id = 319612
	
	-- LeaderBoards
	openFeintLeaderboardIds={814266,814356,814366,814376}
	openFeintTotalScoreId=864486

	-- Achievements
	OF_BlockAchivementIds={1076872,1080332,1080342,1076862}
	OF_L4_AllBalls30SecsId=1080382
	OF_L6_AllBallsAchievementId=1080362
	OF_L9_10BallsAchievementId=1080392
	OF_L12_100SecTimeAchievementId=1080402
	OF_L15_AllBallsAchievementId=1080372
	OF_L17_15BallsAchievementId=1080412
	OF_L20_35BallsAchievementId=1080422
end	


local mainGroup = display.newGroup()

local function main()
	--io.output():setvbuf('no')  
	--game.saveScores() -- Reset Scores
	--game.music=true;
	--game.saveSettings()
	
	--[[
	local t = native.getFontNames()
	for i=1,#t,1 do
		print ("->",t[i])
	end
	--]]
	
	game.loadSettings()
	game.loadScores()
	
	game.playMusic()
	
	if game.gnEnabled then
		gameNetwork.init( "openfeint",of_product_key, of_product_secret, of_name, of_app_id )
	end
	
	--game.execCount=15
	
	mainGroup:insert(director.directorView)
	
	local leftBorder = display.newRect( mainGroup, -50, 0, 50, 320 )
	leftBorder:setFillColor( 0, 0, 0 )

	local rightBorder = display.newRect( mainGroup, 480, 0, 50, 320 )
	rightBorder:setFillColor( 0, 0, 0 )

	local upBorder = display.newRect( mainGroup, 0, 0, 480, -50 )
	upBorder:setFillColor( 0, 0, 0 )

	local bottonBorder = display.newRect( mainGroup, 0, 320, 480, 370 )
	bottonBorder:setFillColor( 0, 0, 0 )
	
	director:changeScene("menu")	
	return true
end

---------------------------------------------------------------
-- Begin
---------------------------------------------------------------

main()

