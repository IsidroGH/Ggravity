--
-- menu.lua
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

local managedObjects = require ("managedObjects")
local msgs = require( "msgs" )
local utils = require("utils")

---------------------------------------------------------------
-- IMPORTS
---------------------------------------------------------------

local ui = require ("ui")
local game = require( "ggravity" )

---------------------------------------------------------------
-- GROUPS
---------------------------------------------------------------

local localGroup = display.newGroup()

---------------------------------------------------------------
-- DISPLAY OBJECTS
---------------------------------------------------------------

local ball
local playButton
local enButton
local spButton
local createBackground

local gameCenterButton 
local scoresButton 
local achivButton 
local enableGNButton 
local appStoreButton

-----------------------------------
-- FUNCTIONS
-----------------------------------

local function playAction ( event )
	game.doClick()
	director:changeScene("levelsel","crossfade")
end

local function settingsAction ( event )
	game.doClick()
	director:changeScene("settings","crossfade")
end

local function helpAction ( event )
	game.doClick()
	director:changeScene("help","crossfade")
end

local function facebookAction ( event )
	game.doClick()
	system.openURL( "http://www.facebook.com/apps/application.php?id=198990080144992" )
end

local function goGameCenter()	
	game.doClick()
	local function testNetworkConnection()
	    local netConn = require('socket').connect('www.apple.com', 80)
	    if netConn == nil then
	        return false
	    end
	    netConn:close()
	    return true
	end
	
	local device = system.getInfo ( "environment" )
    local appURL = "gamecenter:"
    if device == "simulator" then
        print ( "Cannot spawn this URL in the simulator" )
    else
        if testNetworkConnection() then
            system.openURL ( appURL )
		else
			native.showAlert("Unable to connect to Game Center.")
        end
    end
end

local function goScores()
	game.doClick()
	gameNetwork.show( "leaderboards" )
end

local function goAchiv()
	game.doClick()
	gameNetwork.show( "achievements" ) 
end

local function goEnableGN()
	game.doClick()
	gameNetwork.init( "openfeint",of_product_key, of_product_secret, of_name, of_app_id )
	game.gnEnabled=true
	game.saveSettings()
	gameCenterButton.isVisible=true
	scoresButton.isVisible=true
	achivButton.isVisible=true
	enableGNButton.isVisible=false
end

local function goShop()
	system.openURL( ggravityLink )
end


---------------------------------------------------------------
-- INIT VARS
---------------------------------------------------------------

local function initVars ()
	-- Botones
	local settingsButton = ui.newButton{
		default = "settingsbtn.png",
	        over = "settingsbtn_over.png",
		onPress = settingsAction, 
		width=50,
		height=50
	}

	local helpButton = ui.newButton{
		default = "helpbtn.png",
	        over = "helpbtn_over.png",
		onPress = helpAction, 
		width=50,
		height=50
	}

	local facebookButton = ui.newButton{
		default = "fbmenubtn.png",
		onPress = facebookAction, 
		width=30,
		height=30
	}

	gameCenterButton = ui.newButton{
		default = "gamecenter.png",
		onPress = goGameCenter, 
		width=30,
		height=30
	}

	scoresButton = ui.newButton{
		default = "scores.png",
		onPress = goScores, 
		width=50,
		height=50
	}

	achivButton = ui.newButton{
		default = "achiv.png",
		onPress = goAchiv, 
		width=50,
		height=50
	}
	
	enableGNButton = ui.newButton{
		default = "enablegn.png",
		onPress = goEnableGN, 
		width=100,
		height=50
	}
	
	local appStoreImg
	if game.language=="sp" then
		appStoreImg="appstore_sp.png"
	else
		appStoreImg="appstore_en.png"
	end
	
	appStoreButton = ui.newButton{
		default = appStoreImg,
		onPress = goShop, 
		width=116,
		height=40
	}
		
	playButton = utils.createTextButton(msgs.get(59),utils.getDefaultButtonStyle(),localGroup,playAction,false,display.CenterReferencePoint,240,190)
	
	localGroup:insert(settingsButton)
	localGroup:insert(helpButton)
	localGroup:insert(facebookButton)
	localGroup:insert(gameCenterButton)
	localGroup:insert(achivButton)
	localGroup:insert(scoresButton)
	localGroup:insert(enableGNButton)
	localGroup:insert(appStoreButton)
			
	-----------------------------------
	-- Positions
	-----------------------------------
	
	playButton.x = 252
	playButton.y = 290

	settingsButton.x = 50
	settingsButton.y = 290

	helpButton.x = 430
	helpButton.y = 290
	
	facebookButton.x=450
	facebookButton.y=190
	
	gameCenterButton.x=410
	gameCenterButton.y=190
	
	appStoreButton.x=413
	appStoreButton.y=237
	
	scoresButton.x=50
	scoresButton.y=160
	
	achivButton.x=50
	achivButton.y=220
		
	enableGNButton.x=60
	enableGNButton.y=185
		
	if game.gnEnabled then
		gameCenterButton.isVisible=true
		scoresButton.isVisible=true
		achivButton.isVisible=true
		enableGNButton.isVisible=false
	else
		gameCenterButton.isVisible=false
		scoresButton.isVisible=false
		achivButton.isVisible=false
		enableGNButton.isVisible=true
	end
	
	if freeMode then
		appStoreButton.isVisible=true
	else
		appStoreButton.isVisible=false
	end
		
end


local function showRateMessage()
	local function onComplete( event )
		if "clicked" == event.action then
			local i = event.index
			if i==2 then
				if freeMode then
					system.openURL( ggravityFreeLink )
				else
					system.openURL( ggravityLink )
				end
			end
		end
	end

	local alert = native.showAlert( "Ggravity", msgs.get(68), { msgs.get(70), msgs.get(69)  }, onComplete )
end

createBackground=function()
	local background = display.newImageRect( "back.png", 480, 320 )
	background.x=240;background.y=160
	localGroup:insert(background)

	if freeMode then
		utils.drawText("Free", 305 , 90, 60, 255,255,0, localGroup)
	end

	local logoImage = display.newImageRect( "logo.png", 340, 100 )
	logoImage.x=240;logoImage.y=120-40
	localGroup:insert(logoImage)

	local logoApple = display.newImageRect( "logoapple.png", 228, 169 )
	logoApple.x=250;logoApple.y=180
	localGroup:insert(logoApple)

	ball = managedObjects.newObject( { "apple1.png","apple2.png" }, 22, 22, 331, 65-40, {2.0,0.2}, false,1, localGroup,0 )
	ball:scale(1.1,1.1)
	ball:startAnimation()

	ball:toFront()
end

function new()
	createBackground()
	
	if game.execCount==1 then
		game.execCount=2
		local langGroup=display.newGroup()
		
		local function selectLanguage ( lang )            
		  return function ( event )
		  				game.doClick()
		  				if lang ~=game.language then
		  			 		game.language = lang    
		  			 		game.saveSettings()	
		  			 	end
		
						local function onFadeComplete()
							langGroup.isVisible=false
							initVars()	
						end
		
						transition.to( langGroup, { time=500, alpha=0, onComplete=onFadeComplete } )
		     return true
			end        
		end
		enButton = utils.createTextButton("English",utils.getDefaultButtonStyle(),langGroup,selectLanguage("en"),false,display.CenterReferencePoint,180,290)
		spButton = utils.createTextButton("Español",utils.getDefaultButtonStyle(),langGroup,selectLanguage("sp"),false,display.CenterReferencePoint,300,290)
		localGroup:insert(langGroup)
	else
		initVars()
	end
	
	if game.execCount==15 then
		-- Mensaje de comentar		
		game.execCount=game.execCount+1
		timer.performWithDelay( 500, function() showRateMessage();end, 1 )		
	end

	return localGroup
end

function clean()
	ball:destroy()
	ball=nil
	
	utils.removeTextButton(playButton)
	utils.removeTextButton(enButton)
	utils.removeTextButton(spButton)
end
