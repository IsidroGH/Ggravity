--
-- levelsel.lua
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
local utils = require("utils")

local localGroup = display.newGroup()
local levelButtonsGroup
local blocksGroup
local popupGroup
local popupX=240
local popupY=150
local buttonOffset=60
local block1
local block2
local block3
local block4

local msg
local extraLevelsButton


---------------------------------------------------------------
-- INIT VARS
---------------------------------------------------------------

local function goHome()
	game.doClick()
	director:changeScene("menu","crossfade")       
end

local function selectLevelAction ( index )   
  -- Closure wrapper for buyThis() to remember which button
  return function ( event )
  			 game.doClick()
  			 --print ("loading ",index)
			 if game.extraLevelsMode==false then
				-- Niveles normales
  			 	game.currentLevel= "level"..index   
     		 else
				-- Niveles extras
				game.currentLevel= "elevel"..index   
			 end
         director:changeScene(game.currentLevel,"crossfade")         
     return true
	end        
end

local function lockedLevel()
 	game.doClick()
	msg = display.newGroup()	
	utils.drawTextCentered (msgs.get(34), 40, popupY-30, 255,0,0, msg)
	utils.drawTextCentered (msgs.get(35), 40, popupY+10, 255,255,255, msg)
	popupGroup:insert(msg)
end

local function createLevelButton(level, x,y,group)
	local btn
	
	btn = ui.newButton{
				default = "levelbtn.png",
				over = "levelbtn_over.png",
				onPress = selectLevelAction(level), 
        text = level,
        size = 36,
        --emboss = true,
		font="ChubbyCheeks",
        width=48,
		height=48
	}
  
  	btn.x=x;btn.y=y
  	group:insert(btn)
	
	local score
	if game.extraLevelsMode then
		score=game.extraScores[level]
	else
		score=game.mainScores[level]
	end

	if score>0 then
		local img = display.newImageRect( "mark.png", 20, 20 )
  		img.x=x+12; img.y=y+12  
  		group:insert(img)
  	end
end

local function hidePopup()
	game.doClick()
	local function hide()
		popupGroup.isVisible=false
		blocksGroup.alpha=1	
		if levelButtonsGroup then
			levelButtonsGroup:removeSelf()
			levelButtonsGroup=nil
		end
		block1.isEnabled=true
		if freeMode==false then
			block2.isEnabled=true
			block3.isEnabled=true
			block4.isEnabled=true
		end
		popupGroup.alpha=1
		if msg~=nil then
			msg:removeSelf()
			msg=nil
		end
	end
	transition.to( popupGroup, { time=200, alpha=0, onComplete=hide } )	
end

local function createPopup()
	popupGroup = display.newGroup()
	
	local box = display.newRoundedRect( popupGroup, 0,0, 324, 110, 10 )
	box:setFillColor(16, 37, 63)
	box:setStrokeColor(255,255,255)
	box.strokeWidth=1
	
	local cancelBtn = ui.newButton{
				default = "cancelbtn.png",
				over ="cancelbtn_over.png",
				onPress = hidePopup, 
				width=50,
				height=50,
				x=popupX,
				y=popupY+55
  	}

	popupGroup:insert(box)
	popupGroup:insert(cancelBtn)
	
	box:setReferencePoint(display.CenterReferencePoint)
	box.x=popupX;box.y=popupY
	
	popupGroup.x=0;popupGroup.y=0
	popupGroup.isVisible=false	
		
	localGroup:insert(popupGroup)
	
	--[[
	popupGroup = display.newGroup()
	local box = display.newRoundedRect( popupGroup, 0,0, 324, 110, 10 )

	box:setFillColor(16, 37, 63)
	box:setStrokeColor(255,255,255)
	box.strokeWidth=1	
	
	local cancelBtn = ui.newButton{
				default = "cancelbtn.png",
				over ="cancelbtn_over.png",
				onPress = hidePopup, 
				width=50,
				height=50
  	}
  
  cancelBtn.x = popupX+160;cancelBtn.y=210
	
	popupGroup:insert(cancelBtn)
	localGroup:insert(popupGroup)
	
	popupGroup:setReferencePoint(display.CenterReferencePoint)
	popupGroup.x=240;popupGroup.y=0
	popupGroup.isVisible=true
	--]]	
end

local function showPopup()
	transition.to( blocksGroup, { time=100, alpha=0 } )	
	timer.performWithDelay( 100, function()popupGroup.isVisible=true;end, 1 )				
	block1.isEnabled=false
	if freeMode==false then
		block2.isEnabled=false
		block3.isEnabled=false
		block4.isEnabled=false
	end
end

local function selectExtraLevels()
	game.extraLevelsMode=true
	game.doClick()
	showPopup()
	levelButtonsGroup = display.newGroup()	
	
	local buttons = display.newGroup()	
	createLevelButton(1,popupX+40+buttonOffset*0,popupY+58,buttons)
	createLevelButton(2,popupX+40+buttonOffset*1,popupY+58,buttons)
	createLevelButton(3,popupX+40+buttonOffset*2,popupY+58,buttons)
	createLevelButton(4,popupX+40+buttonOffset*3,popupY+58,buttons)
	createLevelButton(5,popupX+40+buttonOffset*4,popupY+58,buttons)
	buttons:setReferencePoint(display.CenterReferencePoint);
	buttons.x=popupX
	buttons.y=popupY	
	levelButtonsGroup:insert(buttons)
	
	utils.drawTextCentered("Extra Levels", 36,111, 255,255,0, levelButtonsGroup)
	
	popupGroup:insert(levelButtonsGroup)
end

local function selectBlock(index)
	game.extraLevelsMode=false
	game.doClick()
	showPopup()
	
	if unlockedMode==false and game.isBlockLocked(index) then
		-- Bloque bloqueado
		lockedLevel()
	else
		levelButtonsGroup = display.newGroup()	
		createLevelButton(1+(index-1)*5,popupX+40+buttonOffset*0,popupY+50,levelButtonsGroup)
		createLevelButton(2+(index-1)*5,popupX+40+buttonOffset*1,popupY+50,levelButtonsGroup)
		createLevelButton(3+(index-1)*5,popupX+40+buttonOffset*2,popupY+50,levelButtonsGroup)
		createLevelButton(4+(index-1)*5,popupX+40+buttonOffset*3,popupY+50,levelButtonsGroup)
		createLevelButton(5+(index-1)*5,popupX+40+buttonOffset*4,popupY+50,levelButtonsGroup)
		levelButtonsGroup:setReferencePoint(display.CenterReferencePoint);
		levelButtonsGroup.x=popupX
		levelButtonsGroup.y=popupY
		popupGroup:insert(levelButtonsGroup)
	end
		
end

local function selectBlockWrapper ( index )            
  return function ( event )  			 
  			     selectBlock(index)          
     return true
	end        
end



local function initVars ()
	--local back = display.newRect( 0, 0, 480, 320 )	
	--back:setFillColor( 16, 37, 63 )
	local background = display.newImageRect( "back.png", 480, 320 )
	background.x=240;background.y=160
	localGroup:insert(background)
	
	--drawText(msgs.get(4),48,200,30,255,255,255,localGroup)	
	utils.drawTextCentered(msgs.get(56),48,23,255,255,255,localGroup)
	
	blocksGroup = display.newGroup()
	
	local xPos=240
	local yPos=70
	local yOffset=55
	local pointsGroup
	
	local style = utils.DefaultButtonStyle
	
	block1 = utils.createCustomBox(380,40,style,blocksGroup,selectBlockWrapper(1),false,display.CenterReferencePoint)	
	utils.drawText(msgs.get(62), 10 , 10, 40, 255,255,255, block1.body)
	utils.drawText(msgs.get(61), 240 , 10, 40, 255,255,0, block1.body)	
	pointsGroup=display.newGroup()
	local w,h = utils.drawText(game.getBlockScore(1), 0 , 0, 40, 255,255,255, pointsGroup)
	pointsGroup.x=380-w-15; pointsGroup.y=10
	block1.body:insert(pointsGroup)
	
	if freeMode==false then 
		-- Modo completo
		block1.x=xPos; block1.y=yPos		
		
		block2 = utils.createCustomBox(380,40,style,blocksGroup,selectBlockWrapper(2),false,display.CenterReferencePoint)	
		utils.drawText(msgs.get(63), 10 , 10, 40, 255,255,255, block2.body)
		block2.x=xPos; block2.y=yPos+yOffset*1
		if game.isBlockLocked(2) then
			local img = display.newImageRect( block2.body, "locked.png", 30, 30 )
			img.x=360;img.y=20
		else
			utils.drawText(msgs.get(61), 240 , 10, 40, 255,255,0, block2.body)
			pointsGroup=display.newGroup()
			local w,h = utils.drawText(game.getBlockScore(2), 0 , 0, 40, 255,255,255, pointsGroup)
			pointsGroup.x=380-w-15; pointsGroup.y=10
			block2.body:insert(pointsGroup)
		end
		
		
		block3 = utils.createCustomBox(380,40,style,blocksGroup,selectBlockWrapper(3),false,display.CenterReferencePoint)	
		utils.drawText(msgs.get(64), 10 , 10, 40, 255,255,255, block3.body)
		block3.x=xPos; block3.y=yPos+yOffset*2
		if game.isBlockLocked(3) then
			local img = display.newImageRect( block3.body, "locked.png", 30, 30 )
			img.x=360;img.y=20
		else
			utils.drawText(msgs.get(61), 240 , 10, 40, 255,255,0, block3.body)
			pointsGroup=display.newGroup()
			local w,h = utils.drawText(game.getBlockScore(3), 0 , 0, 40, 255,255,255, pointsGroup)
			pointsGroup.x=380-w-15; pointsGroup.y=10
			block3.body:insert(pointsGroup)
		end
		
		
		block4 = utils.createCustomBox(380,40,style,blocksGroup,selectBlockWrapper(4),false,display.CenterReferencePoint)	
		utils.drawText(msgs.get(65), 10 , 10, 40, 255,255,255, block4.body)
		block4.x=xPos; block4.y=yPos+yOffset*3
		if game.isBlockLocked(4) then
			local img = display.newImageRect( block4.body, "locked.png", 30, 30 )
			img.x=360;img.y=20
		else
			utils.drawText(msgs.get(61), 240 , 10, 40, 255,255,0, block4.body)
			pointsGroup=display.newGroup()
			local w,h = utils.drawText(game.getBlockScore(4), 0 , 0, 40, 255,255,255, pointsGroup)
			pointsGroup.x=380-w-15; pointsGroup.y=10
			block4.body:insert(pointsGroup)
		end

	else
		-- Modo gratuito
		block1.x=xPos;block1.y=140
	end
	
	style.textRColor=255
	style.textGColor=255
	style.textBColor=0
	
	extraLevelsButton = utils.createTextButton(msgs.get(60),style,blocksGroup,selectExtraLevels,false,display.CenterReferencePoint,240,290)

	localGroup:insert(blocksGroup)
	
	createPopup()
	
	local okButton = ui.newButton{
		default = "homebtn.png",
        over = "homebtn.png",
		onPress = goHome,
		width=50,
		height=50,
		x=450,
		y=290
	}
	
	localGroup:insert(okButton)
	
	
end



---------------------------------------------------------------
-- CLEAN
---------------------------------------------------------------

function clean ( event )
	--extraLevelsButton:removeEventListener( "touch", selectExtraLevels )
	utils.removeTextButton(extraLevelsButton)
	utils.removeCustomBox(block1)
	utils.removeCustomBox(block2)
	utils.removeCustomBox(block3)
	utils.removeCustomBox(block4)
	
	--[[
	collectgarbage( "collect" )   
    print( "memUsage",collectgarbage( "count" ))
    print( "textureMemoryUsed", system.getInfo( "textureMemoryUsed" ) )
	--]]
end

---------------------------------------------------------------
-- NEW
---------------------------------------------------------------

function new()
	
	-----------------------------------
	-- Initiate variables
	-----------------------------------
	initVars()	
	
	--drawStyledNumber(23460000,100,100,1,localGroup)
	
	return localGroup
	
end
