--
-- settings.lua
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
local msgs = require( "msgs" )

local localGroup = display.newGroup()

local flagOffset = 210
local enLang
local spLang

---------------------------------------------------------------
-- INIT VARS
---------------------------------------------------------------

local function drawText(text, size, x , y, r,g,b, group)
	local text = display.newText( text, 0, 0, "ChubbyCheeks", size+13 )
	text.xScale = 0.5; text.yScale = 0.5	--> for clear retina display text
	text.x=(text.contentWidth * 0.5)+x;text.y=y
	text:setTextColor(r, g, b)	
	group:insert(text)	
end

local audioMark
local musicMark
local ambientMark

local function okAction ( event )
	game.doClick()
	game.saveSettings()
	director:changeScene("menu","crossfade")
end

local function toggleAudio ( event )
	if game.audioOn then 
		game.audioOn=false
		game.stopMusic()
	else
		game.audioOn=true
		game.playMusic()
		game.doClick()
	end
	
	audioMark.isVisible=game.audioOn
end

local function toggleMusic ( event )
	game.doClick()
	if game.musicOn then 
		game.musicOn=false
		game.stopMusic()
	else
		game.musicOn=true
		game.playMusic()		
	end
	
	musicMark.isVisible=game.musicOn
end

local function toggleAmbient ( event )
	if game.ambientOn then 
		game.ambientOn=false
	else
		game.ambientOn=true
		game.doClick()
	end
	
	ambientMark.isVisible=game.ambientOn
end

local function remarkLanguage()

	if game.language=="en" then
		enLang.alpha=1
	else
		enLang.alpha=0.4
	end
	
	if game.language=="sp" then
		spLang.alpha=1
	else
		spLang.alpha=0.4
	end
end

local function selectLanguage ( lang )            
  return function ( event )
  				game.doClick()
  				if lang ~=game.language then
  			 		game.language = lang    
  			 		--remarkLanguage()  
  			 		director:changeScene("reload","crossfade")		
  			 	end
     return true
	end        
end

local function initVars ()

	--local back = display.newRect( 0, 0, 480, 320 )	
	--back:setFillColor( 16, 37, 63 )
	--localGroup:insert(back)
	local background = display.newImageRect( "back.png", 480, 320 )
	background.x=240;background.y=160
	localGroup:insert(background)

	drawText(msgs.get(3),56,170,40,255,255,255,localGroup)		
		
	-- Audio
	drawText(msgs.get(1),48,80,100,255,255,0,localGroup)		
	
	local audioButton = ui.newButton{
				default = "checkbox.png",      
				onPress = toggleAudio,
				width=25,
				height=25
	}
	localGroup:insert(audioButton)
	
	audioButton.x = 200; audioButton.y = 100
	audioMark = display.newImageRect("checkmark.png",25,25)
	audioMark.x=200;audioMark.y=100
	localGroup:insert(audioMark)
	
	audioMark.isVisible=game.audioOn
	
	-- Music
	drawText(msgs.get(54),48,80,140,255,255,0,localGroup)		
	
	local musicButton = ui.newButton{
				default = "checkbox.png",      
				onPress = toggleMusic,
				width=25,
				height=25
	}
	localGroup:insert(musicButton)
	
	musicButton.x = 200; musicButton.y = 140
	
	musicMark = display.newImageRect("checkmark.png",25,25)
	musicMark.x=200;musicMark.y=140
	localGroup:insert(musicMark)
	
	musicMark.isVisible=game.musicOn
	
	-- Ambient
	drawText(msgs.get(57),48,80,180,255,255,0,localGroup)		
	
	local ambientButton = ui.newButton{
				default = "checkbox.png",      
				onPress = toggleAmbient,
				width=25,
				height=25
	}
	localGroup:insert(ambientButton)
	
	ambientButton.x = 200; ambientButton.y = 180
	
	ambientMark = display.newImageRect("checkmark.png",25,25)
	ambientMark.x=200;ambientMark.y=180
	localGroup:insert(ambientMark)
	
	ambientMark.isVisible=game.ambientOn
	
	
	-- Language selecction
	
	drawText(msgs.get(2),48,80,220,255,255,0,localGroup)		
	
	enLang = ui.newButton{
				x=flagOffset+40*0,
				y=220,
				default = "enflag.png",      
				onPress = selectLanguage("en")
	}
	
	spLang = ui.newButton{
				x=flagOffset+50*1,
				y=220,
				default = "spflag.png",      
				onPress = selectLanguage("sp")
	}
		
	localGroup:insert(enLang)
	localGroup:insert(spLang)
	
	
	-- Buttons
	
	local okButton = ui.newButton{
		default = "okbtn.png",
        over = "okbtn.png",
		onPress = okAction,
		width=50,
		height=50
	}
	
	okButton.x = 252;okButton.y = 280
	
	localGroup:insert(okButton)
	
	remarkLanguage()
	
end


---------------------------------------------------------------
-- CLEAN
---------------------------------------------------------------

function clean ( event )
	
end

---------------------------------------------------------------
-- NEW
---------------------------------------------------------------

function new()
	
	-----------------------------------
	-- Initiate variables
	-----------------------------------
	initVars()	
	
	return localGroup
	
end


