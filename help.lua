--
-- help.lua
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
local physics = require( "physics" )
local game = require( "ggravity" )
local objects = require( "objects" )

local localGroup = display.newGroup()
local helpGroup = display.newGroup()
local uiGroup = display.newGroup()

local messageParams={}

local lastY
local screenTouched

local msgStonesGroup
local msgRampGroup
local msgElasticGroup
local msgTubeGroup
local msgStaticsGroup
local msgNinGroup

local stone1
local stone2
local stone3
local bamboo1
local elastic
local tube
local stoneStatic
local ninobj
local demoPanelY
local touchMeTween
local demoActive=false

local navPoints={}
local nextButton
local prevButton
local page
local pages={}
local canSwipe
local currentPageTween
local nextPageTween
local images
local demoGroup

--physics.setDrawMode( "hybrid" )

local function okAction ( event )
	game.doClick()
	director:changeScene("menu","crossfade")
end

---------------------------------------------------------------
-- INIT VARS
---------------------------------------------------------------

local function animateImg(img)
	local scaleUp
	local scaleDown
	img.xScale=1
	img.yScale=1
	scaleUp = function()
		img.tx = transition.to( img, { time=1500,xScale=1.1,yScale=1.1, onComplete=scaleDown} )
	end
	
	scaleDown = function()
		img.tx = transition.to( img, { time=1500,xScale=1,yScale=1, onComplete=scaleUp} )
	end
	
	scaleUp()
end

-- X relativo al centro de la imagen
-- Y relativo a la parte superior de la imagen
local function createImage(group, img, width,height,x,y)
	local img = display.newImageRect( group, img, width, height )
	img.x=x;img.y=y+height/2
	--animateImg(img)
	table.insert(images,img)
	return img
end

local function highlightNav(id)
	for i=1,5,1 do
		if i==id then
			navPoints[i].alpha=1
		else
			navPoints[i].alpha=0.3
		end
	end
end

local function createNavigator(group)
	local numPages=5
	local y=295
	local offset=20
	local x=240-(numPages*offset)/2+offset/240
	
	for i=1,5,1 do
		navPoints[i]=display.newCircle(x,y,3)
		navPoints[i].alpha=0.3
		helpGroup:insert(navPoints[i])
		x=x+offset
	end
	
	local function nextPageAction()
		game.doClick()
		if canSwipe==false then
			return
		end
		
		canSwipe=false
		
		local nextPage=page+1
		if nextPage==6 then
			nextPage=1
		end
		highlightNav(nextPage)
		
		--Muevo la pantalla actual a la dcha
		pages[nextPage].x=480	
		
		if 	currentPageTween~=nil then
			transition.cancel(currentPageTween)
		end
		
		if 	nextPageTween~=nil then
			transition.cancel(nextPageTween)
		end
		
		currentPageTween = transition.to( pages[page], { time=500, x=-480 } )	
		nextPageTween = transition.to( pages[nextPage], { time=500, x=0, onComplete=function()canSwipe=true;end } )	
		page=nextPage
	end
	
	local function prevPageAction()
		game.doClick()
		if canSwipe==false then
			return
		end
		
		canSwipe=false
		
		local nextPage=page-1
		if nextPage==0 then
			nextPage=5
		end
		highlightNav(nextPage)
		
		--Muevo la pantalla actual a la izda
		pages[nextPage].x=-480	
		
		if 	currentPageTween~=nil then
			transition.cancel(currentPageTween)
		end
		
		if 	nextPageTween~=nil then
			transition.cancel(nextPageTween)
		end
		
		currentPageTween = transition.to( pages[page], { time=500, x=480 } )	
		nextPageTween = transition.to( pages[nextPage], { time=500, x=0, onComplete=function()canSwipe=true;end } )	
		page=nextPage
	end
	
	
	nextButton = ui.newButton{
		default = "nextbtn.png",
        over = "nextbtn.png",
		onPress = nextPageAction,
		width=50,
		height=50,
	}
	nextButton.xScale=0.5
	nextButton.yScale=0.5
	nextButton.y=y
	nextButton.x = 310
	helpGroup:insert(nextButton)
	
	prevButton = ui.newButton{
		default = "prevbtn.png",
        over = "prevbtn.png",
		onPress = prevPageAction,
		width=50,
		height=50,
	}
	prevButton.xScale=0.5
	prevButton.yScale=0.5
	prevButton.y=y
	prevButton.x = 155
	helpGroup:insert(prevButton)
	
end

local function createDemoPanel(y,group)
	demoPanelY = y+175
	y=demoPanelY
	
	local function showObjectMsg(obj)
		-- Desactivo todos
		msgStonesGroup.isVisible=false
		msgRampGroup.isVisible=false
		msgElasticGroup.isVisible=false
		msgTubeGroup.isVisible=false
		msgStaticsGroup.isVisible=false
		msgNinGroup.isVisible=false
		
		-- Activo el seleccionado
		if obj.msg~=nil then
			obj.msg.isVisible=true
		end
	end
	
	function startDrag( event )
		--print ("StartDrag ", event.phase,event.target.isFocus)
		local t = event.target	
		local phase = event.phase

		local y=textYPos

			local phase = event.phase
			if  (phase == "began" or phase=="moved" and not t.isFocus) and demoActive and not draggedObject then
				group.msg.isVisible=false

				showObjectMsg(t)

			-- Tiene efecto si estoy pulsando en la pantalla y no en la zona de botones		
			-- Ademas solo permito mover un objeto a la vez
				draggedObject=t		
				---disableNonInteractableObjects()	

				display.getCurrentStage():setFocus( t )
				t.isFocus = true

				-- Store initial position
				t.x0 = event.x - t.x
				t.y0 = event.y - t.y
				t.moved=false

				-- Stop current motion, if any
				event.target:setLinearVelocity( 0, 0 )
				event.target.angularVelocity = 0

			elseif t.isFocus then
				local auxY = demoPanelY-t.y
				--print ("mmm",auxY,groundY, helpGroup.y, t.y, event.y)

				if "moved" == phase and t==draggedObject and demoActive and t.type~="static" then
					t.lastValidX = t.x
					t.lastValidY = t.y
					t.bodyType = "kinematic"
					t:setLinearVelocity( 0, 0 )
					t.angularVelocity = 0				
					t.moved=true

					t.x = event.x - t.x0
					t.y = event.y - t.y0


				elseif "ended" == phase or "cancelled" == phase then
					--popupGroup.isVisible=false

					draggedObject=nil
					---enableNonInteractableObjects()

					if t.moved==false and t.type~="static" then
						-- Se ha hecho click 
						t.rotation=t.rotation+90					
					end
					display.getCurrentStage():setFocus( nil )
					t.isFocus = false

					if ( not event.target.isPlatform ) then

						-- La version actual de corona no permite establecer las propiedades de cada elemento
						-- de un complex body. El tube es complejo formado por un sensor, si pongo isSensor=false
						-- me desactiva el sensor interno. Como workarround, en caso de un tube, lo elimino y lo
						-- vuelvo a crear. Tengo crear el tube de nuevo en el evento de soltar si ha pasado
						-- por encima de un noninteractable porque mientras se movia se ha puesto sensor=false 
						if t.name~="tube" or (t.name=="tube" and not t.touchedNonInteractable) then
							event.target.bodyType = event.target.mode
						else
							-- Solo creo el tube si ha pasado por encima de un noninteractable
							local power = t.power
							local x = t.x
							local y = t.y
							t.isSensor=true
							removeDragableObj(t)
							t:removeSelf()

							timer.performWithDelay( 1, function()local tube = objects.createTube(x,y,power, frontGroup);setDragable(tube);end, 1 )
						end
					end

				end
			end



		-- Stop further propagation of touch event!
		return true
	end

	
	local rect = display.newRect( 0, demoPanelY-170 , 480, 145 )
	rect:setFillColor( 165, 217, 243,255 ) 
	group:insert(rect)
	
	local ground1 = display.newImageRect( "grounddemo.png", 480, 44 )
	ground1:setReferencePoint( display.BottomLeftReferencePoint )
	ground1.x = 0; ground1.y = demoPanelY
	
	local groundShape = { -240,-3, 300,-3, 300,50, -240,50 }
	physics.addBody( ground1, "static",{ density=10000.0, bounce=0.3, friction=0.5, shape=groundShape } )
	
	group:insert(ground1)
	
	messageParams.textSize=30
	messageParams.lineLen=60
		
	-- Piedras
	msgStonesGroup = utils.createMessage(msgs.get(22).." "..msgs.get(23),messageParams,group,display.TopCenterReferencePoint,240,0)
	msgStonesGroup.isVisible=false

	-- Rampa
	msgRampGroup = utils.createMessage(msgs.get(24),messageParams,group,display.TopCenterReferencePoint,240,0)
	msgRampGroup.isVisible=false	
	
	-- Elástico
	msgElasticGroup = utils.createMessage(msgs.get(25).." "..msgs.get(26),messageParams,group,display.TopCenterReferencePoint,240,0)
	msgElasticGroup.isVisible=false
	
	-- Tubo
	msgTubeGroup = utils.createMessage(msgs.get(27),messageParams,group,display.TopCenterReferencePoint,240,0)
	msgTubeGroup.isVisible=false

	-- Objetos estáticos
	msgStaticsGroup = utils.createMessage(msgs.get(29),messageParams,group,display.TopCenterReferencePoint,240,0)
	msgStaticsGroup.isVisible=false
	
	-- Objetos no interactuables
	msgNinGroup = utils.createMessage(msgs.get(31),messageParams,group,display.TopCenterReferencePoint,240,0)
	msgNinGroup.isVisible=false	

	stone1 = objects.createSmallStone(50,demoPanelY-160,{ density=100.0, friction=0.5, bounce=0.0  },group)
	stone1.msg=msgStonesGroup
	stone1:addEventListener( "touch", startDrag )	
	
	stone2 = objects.createSrqStone(100,demoPanelY-150,{ density=100.0, friction=0.5, bounce=0.0  },group)
	stone2.msg=msgStonesGroup
	stone2:addEventListener( "touch", startDrag )
	
	stone3 = objects.createBigStone(150,demoPanelY-130,{ density=100.0, friction=0.5, bounce=0.0  },group)
	stone3.msg=msgStonesGroup
	stone3:addEventListener( "touch", startDrag )
	
	
	bamboo1 = objects.createBamboo(340,demoPanelY-160,{ density=50, friction=0.5, bounce=0.0  }, group)
	bamboo1:addEventListener( "touch", startDrag )
	bamboo1.msg=msgRampGroup
	
	elastic = objects.createElastic(220,demoPanelY-140, 0.9, group)
	elastic:addEventListener( "touch", startDrag )
	elastic.msg=msgElasticGroup
	
	tube = objects.createTube(400,demoPanelY-130,17,group)
	tube:addEventListener( "touch", startDrag )
	tube.msg=msgTubeGroup
	
	stoneStatic = objects.createBigStone(320,demoPanelY-55,{ density=100.0, friction=0.5, bounce=0.2  },group,"static")
	stoneStatic.msg=msgStaticsGroup
	stoneStatic:addEventListener( "touch", startDrag )
	stoneStatic.type="static"
	
	-- Dinamicos
	ninobj = display.newImageRect( group, "sqrstoneni.png",30,30 )
	physics.addBody( ninobj, "static", { density=100.0, friction=0.5, bounce=0.2  } )
	ninobj.x=440;ninobj.y=demoPanelY-40
	ninobj.type="static"
	ninobj:addEventListener( "touch", startDrag )
	ninobj.msg=msgNinGroup

	
	local touchMeGroup = display.newGroup()
	local touchMeRect = display.newRect( 0, demoPanelY-170 , 480, 170 )
	touchMeRect:setFillColor( 0, 0, 0, 200 ) 
	touchMeGroup:insert(touchMeRect)
	
	local touchMeImg = display.newImageRect( "touchme.png", 70, 99 )
	touchMeImg.x=240;touchMeImg.y=demoPanelY-85
	touchMeGroup:insert(touchMeImg)
		
	group:insert(touchMeGroup)
	
	local function onTouchMe()
		--print ("touchme")
		touchMeGroup:removeEventListener("touch",onTouchMe)
		
		local function onHideTouchMe()
			physics.start()
			demoActive=true
		end
		touchMeTween = transition.to( touchMeGroup, { time=500, alpha=0, onComplete=onHideTouchMe } )	
	end
	touchMeGroup:addEventListener( "touch", onTouchMe )
	
	
	Runtime:addEventListener( "collision", game.onCollision )
end

local function generateHelp()	
	messageParams.textSize=36
	messageParams.lineLen=50
	local msg
	
	-- Page 1
	pages[1] = display.newGroup()	
	msg = utils.createMessage(msgs.get(14),messageParams,pages[1],display.TopCenterReferencePoint,240,10)
	pages[1].msg=msg
	createImage(pages[1] ,"r_l1_unresolved.png",200, 140 ,240-120,msg.messageHeight+30)	
	createImage(pages[1] ,"r_l1_resolved.png",200, 140 ,240+120,msg.messageHeight+30)	
	pages[1].x=0
	helpGroup:insert(pages[1])

	-- Page 2
	pages[2] = display.newGroup()	
	msg = utils.createMessage(msgs.get(15),messageParams,pages[2],display.TopCenterReferencePoint,240,10)
	pages[2].msg=msg
	createImage(pages[2] ,"r_objectmove.png",200, 140 ,240,msg.messageHeight+50)	
	pages[2].x=-480
	helpGroup:insert(pages[2] )
	
	-- Page 3
	demoGroup = display.newGroup()	
	pages[3] = demoGroup	
	msg = utils.createMessage(msgs.get(17),messageParams,pages[3],display.TopCenterReferencePoint,240,10)
	pages[3].msg=msg
	demoPanelY=100
	createDemoPanel(demoPanelY,pages[3])
	pages[3].x=-480
	helpGroup:insert(pages[3] )
	
	-- Page 4
	messageParams.textSize=36
	messageParams.lineLen=50
	pages[4] = display.newGroup()	
	msg = utils.createMessage(msgs.get(31),messageParams,pages[4],display.TopCenterReferencePoint,240,10)
	pages[4].msg=msg	
	createImage(pages[4] ,"helpni.png",180, 172 ,240,msg.messageHeight+15)	
	pages[4].x=-480
	helpGroup:insert(pages[4] )
	
	-- Page 5
	pages[5] = display.newGroup()	
	msg = utils.createMessage(msgs.get(16),messageParams,pages[5],display.TopCenterReferencePoint,240,10)
	pages[5].msg=msg	
	createImage(pages[5] ,"r_zoom.png",200, 140 ,240-120,msg.messageHeight+50)	
	createImage(pages[5] ,"r_screenmove.png",200, 140 ,240+120,msg.messageHeight+50)	
	pages[5].x=-480
	helpGroup:insert(pages[5] )
		
	createNavigator(helpGroup)
	
	highlightNav(1)		
end

local onScreenTouch = function( event )
	if event.phase == "began" then
		local auxY = demoPanelY-(event.y-helpGroup.y)
		
		if auxY<50 or auxY>170 then
			popupGroup.isVisible=false
			screenTouched=true
			lastY = event.y
		end
	elseif event.phase == "moved" and screenTouched==true then
		local offset = lastY - event.y
		lastY = event.y
		
		--print (lastY, event.y, offset,helpGroup.y-offset) 
		
		if offset-helpGroup.y>0 and offset-helpGroup.y < maxHeight then
			helpGroup.y=helpGroup.y-offset
		end
	elseif event.phase == "ended" then
		screenTouched=false
	end
end



local function initVars ()
	messageParams.x=0;messageParams.y=0
	messageParams.lineLen=50
	messageParams.textSize=36
	messageParams.xMargin=10;messageParams.yMargin=10
	messageParams.textRColor=255;messageParams.textGColor=255;messageParams.textBColor=255
	messageParams.fillRColor=0;messageParams.fillGColor=100;messageParams.fillBColor=200
	messageParams.borderSize=0;messageParams.borderRColor=0;messageParams.borderGColor=0;messageParams.borderBColor=0
	
	images={}
	canSwipe=true
	page=1
	pages={}
	local back = display.newImageRect( "back.png", 480, 320 )
	back.x=240;back.y=160
	--localGroup:insert(background)
	
	generateHelp()
	
	-- Buttons	
	local okButton = ui.newButton{
				default = "okbtn.png",
        over = "okbtn.png",
				onPress = okAction,
				width=40,
				height=40,
	}
	
	
	okButton.x = 455;okButton.y = 295
	uiGroup:insert(okButton)
	
	
	local leftBorder = display.newRect( uiGroup, -50, 0, 50, 320 )
	leftBorder:setFillColor( 0, 0, 0 )
	
	local rightBorder = display.newRect( uiGroup, 480, 0, 50, 320 )
	rightBorder:setFillColor( 0, 0, 0 )
	
	local upBorder = display.newRect( uiGroup, 0, 0, 480, -50 )
	upBorder:setFillColor( 0, 0, 0 )
	
	local bottonBorder = display.newRect( uiGroup, 0, 320, 480, 370 )
	bottonBorder:setFillColor( 0, 0, 0 )

	
	localGroup:insert(back)
	localGroup:insert(helpGroup)
	localGroup:insert(uiGroup)
	
	-----Runtime:addEventListener( "touch", onScreenTouch )
	
end

---------------------------------------------------------------
-- CLEAN
---------------------------------------------------------------

function clean ( event )
	---- img.tx Limpiar las transiciones de las imagenes
	for i=#images,1,-1 do
		if images[i].tx~=nil then 
			transition.cancel(	images[i].tx )
		end
		images[i]:removeSelf()
	end
	
	images=nil
	
	if 	currentPageTween~=nil then
		transition.cancel(currentPageTween)
	end
	
	if 	nextPageTween~=nil then
		transition.cancel(nextPageTween)
	end
	

	Runtime:removeEventListener( "touch", onScreenTouch )
	Runtime:removeEventListener( "collision", game.onCollision )
	stone1:removeEventListener("touch",startDrag)
	stone2:removeEventListener("touch",startDrag)
	stone3:removeEventListener("touch",startDrag)
	bamboo1:removeEventListener("touch",startDrag)
	elastic:removeEventListener("touch",startDrag)
	tube:removeEventListener("touch",startDrag)
	stoneStatic:removeEventListener("touch",startDrag)	
	ninobj:removeEventListener("touch",startDrag)
	
	if touchMeTween then transition.cancel( touchMeTween ); end
	
	pages=nil
	
	-- Elimino los objetos dinamicos
	game.removeManagedImages(demoGroup)
	
	physics.stop()
	
	--collectgarbage( "collect" )   
    --print( "memUsage",collectgarbage( "count" ))
    --print( "textureMemoryUsed", system.getInfo( "textureMemoryUsed" ) )
end

---------------------------------------------------------------
-- NEW
---------------------------------------------------------------

function new()
	physics.start()
	physics.pause()
	--printMultilineText()
	-----------------------------------
	-- Initiate variables
	-----------------------------------
	initVars()	
		
	return localGroup
	
end
