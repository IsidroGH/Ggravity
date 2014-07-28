--
-- ggravity.lua
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

local facebook = require("facebook")
local managedObjects = require( "managedObjects" )
local physics = require( "physics" )
local msgs = require( "msgs" )

-- Listeners
onThrowBall=nil
onEndLevel=nil
onCreateNextBall=nil
onGameOver=nil

---- Multitouch
local onScreenTouch
local mt_distance
local mt_newDistance
local mt_zoom
local swipeTouchId
----
local firstTouch
local pioneerAction
local getCeilingY
local disableSwipeThrowingBall

--local debug=true
local debug=false

-- Public
gnEnabled=false
execCount=1
mainScores = {}
extraScores = {}
local scores=nil
audioOn = true
musicOn = true
ambientOn = true
extraLevelsMode=false

local adOffset=0
local startCurrentXScreen, startCurrentYScreen
local canDrag
local lastTrailX, lastTrailY
local swipeForce
local swipeTimer
local offsetY

local nonInteractableObjects
local dragableObjs
local currentBall
local nextBall

local stopTry
local sentToFacebook
local getCurrentBlock

language="en"

-- Private
local levelGroup
local middleGroup
local frontGroup
local backGroup
local uiGroup
local scenario
local popupGroup

-- Elementos del UI

-- Botones de popup
local okButton
local fbButton
local nextButton
local restartButton
local menuButton

local shadeRect
local endButton
local zoominButton
local zoomoutButton
local currentZoom

local zoom
local xScreens
local yScreens
local totalTime
local totalBalls
local goalBalls

local nonIteractableTimer
local swipeTween
local nextBallTween
local nextBallTimer

-- Timers
local endPlayDetectorTimer
local dotTimer
local checkOutLimitsTimer

local isPopup
local falling
local count
local timeText
local ballsText
local scoreText
local score
local basket
local tree
local draggedObject
local trailGroup

local framesPerSec=30	-- 1 seg
local currentFrames

local level,levelMessage1,levelMessage2

local basketX, basketY

-- Funciones
local removeDragableObj
local removeBalls
local enableNonInteractableObjects
local disableNonInteractableObjects
local showMessage
local drawText
local okButtonAction
local nextButtonAction
local removeTrail
local applyZoom
local gameOver

local rnd = 0
local thrownBalls

local failSound = audio.loadSound( "fail.wav" )
local successSound = audio.loadSound( "success.wav" )
local clickSound = audio.loadSound( "click.wav" )
local clackSound = audio.loadSound( "clacksound.wav" )
local goalSound = audio.loadSound( "goal.wav" )
local impactSound = audio.loadSound( "impact.wav" )
local poofSound = audio.loadSound( "poof.wav" )
local touchAppleSound = audio.loadSound( "touchapple.wav" )

local leftTime

local currentXScreen		
local currentYScreen

local leftMargin, rightMargin, topMargin, bottonMargin


-- Banners
local adX = 480-320
local adY=0

local function showAd(event)
	-- Is the url a remote call?
	if string.find(event.url, "http://", 1, false) == 1 then
		-- Is it a call to the admob server?
		if string.find(event.url, "c.admob.com", 1, false) == nil then
			adSpace.url = event.url
		else
			-- an actual click on an ad, so open in Safari
			system.openURL(event.url)
			removeAd(0)
			displayAd(0)
		end
	else
		print("loading an ad")
		return true
	end
end

function displayAd(t)
        native.cancelWebPopup()
        timer.performWithDelay(t, function()
                	native.showWebPopup(adX, adY, 320, 48, "ad.html", {baseUrl = system.ResourceDirectory, hasBackground = false, urlRequest = showAd})
                end
        )
end
 
function removeAd(t)
        timer.performWithDelay(t, native.cancelWebPopup)
end
-- Fin Banners		

local function printDebug(msg)
	if debug then 
		print (msg); 
	end
end

playMusic = function()
	if audioOn and musicOn then 
		media.playSound( "music.mp3",true)
	end
end

stopMusic = function()
	media.stopSound()
end

local function playAmbientSound()
	if audioOn and ambientOn then 
		media.playSound( "AmbientSound.mp3",true)
	end
end

local function stopAmbientSound()
	if audioOn then 
		media.stopSound()
	end
end

local function play(sound)
	if audioOn then 
  	audio.play( sound )
  end
end

doClick = function()
	play( clickSound)
end

-- Convierte un numero a una lista de digitos invertida
local function int2List(number)
	local list = {}
	while number>=10 do
		local aux=math.floor(number/10)
		local remainder = number-10*aux
		number=aux
		table.insert(list,remainder)
	end
	
	table.insert(list,number)
	return list
end

function displayPoof(x,y,group)
				local poof = display.newImageRect( "poof.png", 80, 70 )
				poof.alpha = 1.0
				poof.isVisible = true
				
				poof.x=x
				poof.y=y
				
				group:insert(poof)
				
				local fadePoofComplete = function(obj)
					-- Tengo que hacer esta comprobacion para no eliminar 
					-- el objeto de nuevo en caso de que se haya llamado a clean
					if obj.removeSelf then
						obj:removeSelf()
					end
				end
								
				local fadePoof = function()
					transition.to( poof, { time=500, alpha=0, onComplete=fadePoofComplete } )	
				end
				transition.to( poof, { time=50, alpha=1.0, onComplete=fadePoof } )
end


function disableButtons()
  endButton.isVisible=false
	zoominButton.isVisible=false	
	zoomoutButton.isVisible=false	
end

function startDrag( event )
	--print ("StartDrag ", event.phase,event.target.isFocus)
	local t = event.target	
	local phase = event.phase
	
		local phase = event.phase
		if  (phase == "began" or phase=="moved" and not t.isFocus) and playing and not draggedObject and canDrag then
		-- Tiene efecto si estoy pulsando en la pantalla y no en la zona de botones		
		-- Ademas solo permito mover un objeto a la vez
			draggedObject=t	
			draggedObject.touchId=event.id
			disableNonInteractableObjects()	
			
			display.getCurrentStage():setFocus( t )
			t.isFocus = true
	
			-- Store initial position
			t.x0 = event.x/zoom - t.x
			t.y0 = event.y/zoom - t.y
			t.moved=false

			-- Stop current motion, if any
			event.target:setLinearVelocity( 0, 0 )
			event.target.angularVelocity = 0
	
		elseif t.isFocus then
			if "moved" == phase and t==draggedObject and playing and event.id==draggedObject.touchId then
				--print ("Pos:",t.x,t.y)			
				t.lastValidX = t.x
				t.lastValidY = t.y
				t.bodyType = "kinematic"
				t:setLinearVelocity( 0, 0 )
				t.angularVelocity = 0				
				t.moved=true
				if event.target.name~="Ball" then 
					if not debug then removeBalls(false); end
				end;	
				
				t.x = event.x/zoom - t.x0
				t.y = event.y/zoom - t.y0
	
			elseif "ended" == phase or "cancelled" == phase and event.id==draggedObject.touchId then
				if debug then print ("Pos:",t.x,t.y,t.rotation); end
				
				draggedObject=nil
				enableNonInteractableObjects()
				
				if not t.moved then
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
						--local tube = objects.createTube(x,y,power, frontGroup)
						--setDragable(tube)
					end
				end
	
				--physics.start()
			end
		end
	
	-- Permito propagar el evento touch
	return false
end

function reorder()
	--backGroup:toFront()
	trailGroup:toFront()
	middleGroup:toFront()	
	frontGroup:toFront()
	basket:toFront()
	uiGroup:toFront()
end

-- Crea una bola
local function createNextBall()
	if onCreateNextBall~=nil then
		onCreateNextBall()
	end
	
	nextBall = managedObjects.newObject( { "apple1.png","apple2.png" }, 22, 22, 60+rnd, -15, {2.0,0.2}, false,1, middleGroup,0 )
	nextBall:startAnimation()
	nextBall.ready=false
	
	--[[
	if (rnd==0) then
		rnd=1
	else
		rnd=0
	end
	--]]
	
	physics.addBody( nextBall, "static", { density=5, bounce=0.2, friction=0.5, radius=10 } )
	nextBall.angularDamping = 0.2
	nextBall.name ="Ball"
	middleGroup:insert(nextBall)
	reorder()			
	
	nextBall:addEventListener( "touch", pioneerAction )
	if debug then nextBall:addEventListener( "touch", startDrag ); end
	
	nextBall.mode="dynamic"
	nextBall.isBodyActive=false
	nextBallTween = transition.to( nextBall, { time=300, y=15, onComplete=function()nextBall.ready=true;end } )	
end


local function throwBall()	
	play(touchAppleSound)	
	
	thrownBalls = thrownBalls + 1
	currentBall = nextBall
	nextBall=nil
	ballsText.text = count.."/"..(totalBalls-thrownBalls)
	currentBall.bodyType="dynamic"
	currentBall.thrown=true
	currentBall.isBodyActive=true
	
	if onThrowBall~=nil then
		onThrowBall()
	end
end

local function createStaticObjects()
	-- Crea la cesta
	basket = display.newImageRect( "basket.png" ,43,31 )
	basket:setReferencePoint( display.BottomLeftReferencePoint )
	local basketRightShape = {18,15,18,-15,22,-15,22,15}
	local basketLeftShape = {-18,15,-18,-15,-15,-15,-15,15}
	basket.x = basketX; basket.y = basketY-55; 
	physics.addBody( basket, "static", 
		{ density=1.0, bounce=0.3, friction=0.5, shape=basketLeftShape},
		{ density=1.0, bounce=0.3, friction=0.5, shape=basketRightShape} )
	
	-- Sensor de la cesta
	local basketSensor = display.newRect( 0, 0, 35, 15 )
	basketSensor:setReferencePoint( display.BottomLeftReferencePoint )
	basketSensor.x=basketX+5;basketSensor.y=basketY-60
	basketSensor.isVisible = false 
	physics.addBody( basketSensor, "static", { isSensor = true } )
	basketSensor.name ="Basket"
	
	frontGroup:insert(basket)
	frontGroup:insert(basketSensor)
	
	-- Creo el arbol
	tree = display.newImageRect( "tree.png", 87,88 )
	tree:setReferencePoint( display.BottomLeftReferencePoint )
	tree.x=0;tree.y=22
	
	frontGroup:insert(tree)
end

function showPoints(id,x,y,deltaX,deltaY,time,group,iniScale, endScale)

	if iniScale==nil then iniScale=1; end
	if endScale==nil then endScale=1; end
 
	local points = drawText(id,48,x,y,255,255,0,group)
	points:scale(iniScale,iniScale)
	
	group:insert(points)
	
	local function pointsComplete()
		points:removeSelf()
		points=nil
	end
	
	transition.to( points, { time=time, xScale=endScale, yScale=endScale , alpha=0, x=points.x+deltaX,y=points.y+deltaY, onComplete=pointsComplete } )
end

local function refreshScoreAndBalls()
	ballsText.text = count.."/"..(totalBalls-thrownBalls)
  if count>=goalBalls then               				
  	ballsText:setTextColor(0, 255, 0,180)
  end
  
  scoreText.text=score   
end

-- Si un obj dragable toca a uno no interactuable se
-- explota al dragable y se vueelve a lanzar desde arriba
local function onNonIteractablePreCollision( self, event )
	--print ("onNonIteractablePreCollision")
	if event.other.isDraggable then
		local otherObj = event.other
		
		local function resetPosition()
		
			-- La version actual de corona no permite establecer las propiedades de cada elemento
			-- de un complex body. El tube es complejo formado por un sensor, si pongo isSensor=false
			-- me desactiva el sensor interno. Como workarround, en caso de un tube, lo elimino y lo
			-- vuelvo a crear
			if otherObj.name~="tube" then
				otherObj.x=150
				otherObj.y=getCeilingY()
				otherObj.bodyType="dynamic"
				otherObj.isSensor=false
				otherObj.isBodyActive=true
				otherObj.isVisible=true
			else
				local power = otherObj.power
				removeDragableObj(otherObj)
				otherObj:removeSelf()
				
				local tube = objects.createTube(150,getCeilingY(),power, frontGroup)
				setDragable(tube)
			end
		end
		
		local function resetPosition2()
			otherObj.bodyType="dynamic"
			otherObj.isSensor=false
		end
		
		otherObj.isSensor=true
		otherObj.bodyType="static"
		otherObj.touchedNonInteractable=true
		
		if draggedObject == otherObj then
			--Si el objeto que colisiona con el noninteractable es el que
			-- estoy dragging, lo vuelvo activo para que explote una vez lo suelto
			timer.performWithDelay( 1, resetPosition2, 1 )
		else
			otherObj.isVisible=false 
			displayPoof(otherObj.x,otherObj.y,frontGroup)
			timer.performWithDelay( 200, resetPosition, 1 )
		end
		
	end
end


		

-- Deteccion de colisiones
function onCollision( event )
        if ( event.phase == "began" ) then
						local customSound1
						local customSound2
						
						if event.object1.onCollision then 
							customSound1 = event.object1.onCollision(event.object1,event.element1,event.object2) 
						end
						if event.object2.onCollision then 
							customSound2 = event.object2.onCollision(event.object2,event.element2,event.object1) 
						end
						
						if audioOn then 
							if customSound1~=nil or customSound2~=nil then
								if customSound1~=nil then
									audio.play( customSound1 )
								end
								if customSound2~=nil then
									audio.play( customSound2 )
								end
							else
								audio.play( impactSound )
							end
						end
        		
        		if ( event.object1.name and event.object2.name ) then 
        			if ( 
        				(event.object1.name == "Ball" and event.object2.name == "Basket") or
        				(event.object1.name == "Basket" and event.object2.name == "Ball")) then 
                		--print( "Encestado" )                		
                		showPoints(100,event.object1.x,event.object1.y-40,0,-80,800,frontGroup,0.5,2)                		
                		
                		play ( goalSound )
                		
               			count  = count+1
               			score=score+100
               			
               			refreshScoreAndBalls()
               			
               			-- Destruyo la bola
               			local ball = event.object1.name == "Ball" and event.object1 or event.object2
               			
               			if ball==currentBall then
               				-- Si es la bola actual paro el timer qe pinta el rastro antes de destruir la bola
               				if dotTimer then 
               					timer.cancel(dotTimer)
               				end
               			end
               			
               			ball:destroy()
						ball=nil
                	end
                end
 		end
end
 

local function removeBallsAction()
	removeBalls(false)
end

removeBalls=function(silentPoof)
	removeTrail()

	removed = false
	
	for i = middleGroup.numChildren,1,-1 do
			local child = middleGroup[i]
			if (child.name=="Ball" and child.thrown) then
				displayPoof(child.x,child.y,middleGroup)
				child:removeEventListener( "touch", child )
				child:destroy()
				child = nil
				removed=true
			end
	end

	if removed and silentPoof == false then
		play ( poofSound )
	end
end

removeTrail = function ()
	if dotTimer then
		timer.cancel(dotTimer)
	end
	
	for i = trailGroup.numChildren,1,-1 do
		local child = trailGroup[i]
		child.parent:remove( child )
		child = nil
	end
end

local function removeBall( self, event )
	if event.phase=="began" then
		removeTrail()
		displayPoof(self.x,self.y,middleGroup)
		self:removeEventListener( "touch", self )
		self:destroy()
		self = nil
		play ( poofSound )
	end
end

pioneerAction = function(event)	
	if event.phase=="began" or event.phase=="moved" then
		disableSwipeThrowingBall=true
		canDrag=false
		--display.getCurrentStage():setFocus( event.target )

		if thrownBalls<totalBalls and nextBall and nextBall.ready then
			doClick()
			throwBall()
			currentBall.trailNum = 0
			currentBall:removeEventListener( "touch", pioneerAction )
		
			currentBall.touch = removeBall
		
			local localBall=currentBall
			
			local function addTouchEvent()
				-- Puede darse el caso que justo cuando tiro la bola, muevo un objeto y la destruye
				-- Como este timer se lanza 1 segundo despues la bola ya no existiria
				-- Cuando la bola se destruye se pone su nombre a nil
				if localBall.name~=nil then
					localBall:addEventListener( "touch", localBall )
				end
			end
			
			timer.performWithDelay( 1000,addTouchEvent,1)
		
			removeTrail()
		
			if thrownBalls==totalBalls then			
				local function onEnPlayDetector()
					local allStoped=true
					local thereAreBalls=false
				
					for i = middleGroup.numChildren,1,-1 do
						local child = middleGroup[i]
						if (child.name=="Ball") then
							thereAreBalls=true
							local vx, vy = child:getLinearVelocity()
							--print ("V",vx*vx+vy*vy);
							if vx*vx+vy*vy>5 then
								allStoped=false
								break
							end
						end
					end
				
					if allStoped then
						stopTry=stopTry+1
					else
						stopTry=0
					end
				
					if stopTry>3 or thereAreBalls==false then
						if endPlayDetectorTimer then timer.cancel( endPlayDetectorTimer ); end
						gameOver(false)
						stopTry=0
					end
				
				end
			
				-- Lanzo el timer de deteccion de fin de partida
				endPlayDetectorTimer = timer.performWithDelay( 1000, onEnPlayDetector, 0 )
			
				-- Se ha alcanzado el numero maximo de bolas del nivel
				falling=true
			else
				-- Aun quedan bolas por caer
				nextBallTimer = timer.performWithDelay( 500, function()createNextBall();end, 1 )
			end
		
			local createDot = function()	
				-- Solo pinto el trail si el ultimno trail 
				local dist = (currentBall.x-lastTrailX)*(currentBall.x-lastTrailX)+(currentBall.y-lastTrailY)*(currentBall.y-lastTrailY)
			
				if dist>60 then 
					local trailDot
				
					if currentBall.trailNum == 0 then
						trailDot = display.newCircle( trailGroup, currentBall.x, currentBall.y, 2.5 )
					else
						trailDot = display.newCircle( trailGroup, currentBall.x, currentBall.y, 1.5 )
					end
					trailDot:setFillColor( 255, 255, 255, 255 )
					trailDot.alpha = 1.0
								
					if currentBall.trailNum == 0 then
						currentBall.trailNum = 1
					else
						currentBall.trailNum = 0
					end
				
					lastTrailX=currentBall.x
					lastTrailY=currentBall.y
				end
			end
		
			lastTrailX=currentBall.x
			lastTrailY=currentBall.y
		
			dotTimer = timer.performWithDelay( 70, createDot, 100 )
		
		end
	end
end


local function endAction()
	physics.pause()
	removeTrail()
	gameOver(true)
	falling=false
end

local function zoomin()	
	doClick()
	if currentZoom<1.75 then
		currentZoom=currentZoom+0.25
		applyZoom(currentZoom)
	end
end

local function zoomout()	
	doClick()
	if currentZoom>0.5 then --  and (xScreens*(currentZoom-0.05)>=1 or yScreens*(currentZoom-0.05)>=1) then
		currentZoom=currentZoom-0.25
		applyZoom(currentZoom)
	end	
end

local function createUI ()
  endButton = ui.newButton{
				default = "xbtn.png",
        over = "xbtn.png",
				onPress = endAction, 
				width=29,
				height=29
  }
  
  
  zoominButton = ui.newButton{
				default = "zoomin.png",
        over = "zoomin_over.png",
				onPress = zoomin,
				width=29,
				height=29
  }
  
  zoomoutButton = ui.newButton{
				default = "zoomout.png",
        		over = "zoomout_over.png",
				onPress = zoomout,
				width=29,
				height=29
  }
  
  zoomoutButton.x=350
  zoomoutButton.y=305
  
  zoominButton.x=390
  zoominButton.y=305  
	
  endButton.x = 460
  endButton.y = 305
	  
  uiGroup:insert(endButton)		
  uiGroup:insert(zoominButton)	
  uiGroup:insert(zoomoutButton)	
  
  disableButtons()
	
	-- Popup
	local popupBox = display.newImageRect( "message.png", 390, 154 )
	popupBox.x = 240; popupBox.y = 165
	popupGroup:insert(popupBox)
		
	function hidePopup()
		popupGroup.body:removeSelf()
		popupGroup.body=nil
		popupGroup.isVisible=false
		shadeRect.isVisible=false
	end

	-- Acciones de los botones
	
	local fbButtonAction = function()
		if sentToFacebook == false then
			doClick()
			
			local fbAppID = "198990080144992"	
					
			local facebookListener = function( event )
				if ( "session" == event.type ) then
					-- upon successful login, update their status
					if ( "login" == event.phase ) then
					
						local statusUpdate = msgs.get(42) .. score .. msgs.get(43) .. level .. msgs.get(44)
						local linkName = msgs.get(45)
						local captionText = msgs.get(46)
						local descriptionText = msgs.get(47)
					
						
						facebook.request( "me/feed", "POST", {
							message=statusUpdate,
							name=linkName,
							caption=captionText,
							description=descriptionText,
							link="http://sites.google.com/site/ggravitysoft",
							picture="http://sites.google.com/site/ggravitysoft/files/fblogo90x90.png" } )
					end
				end
			end
					
			facebook.login( fbAppID, facebookListener, { "publish_stream" } )
			
			sentToFacebook=true
			local mark = display.newImageRect( "mark.png", 21, 20 )
			mark.x=fbButton.x+8
			mark.y=fbButton.y+8
			popupGroup:insert(mark)
	end
	
		
	end
	
	local okButtonWrapperAction = function()
		doClick()
		okButtonAction()
	end
	
	local nextButtonWrapperAction = function()
		doClick()
		nextButtonAction()
	end
	
	local restartButtonAction = function()
		doClick()
		director:changeScene("loadlevel","crossfade")
	end
	
	local menuButtonAction = function()
		doClick()
		playMusic()
		director:changeScene("menu","crossfade")
	end
	
	-- Botones del popup

	fbButton = ui.newButton{
		default = "fbbtn.png",
		over = "fbbtn.png",
		onPress = fbButtonAction,
		width=50,
		height=50		
	}
	fbButton.isVisible = false
	fbButton.isActive = false

	nextButton = ui.newButton{
		default = "nextbtn.png",
		over = "nextbtn.png",
		onPress = nextButtonWrapperAction,
		width=50,
		height=50		
	}
	nextButton.isVisible = false
	nextButton.isActive = false
	
	okButton = ui.newButton{
		default = "okbtn.png",
		over = "okbtn.png",
		onPress = okButtonWrapperAction,
		width=50,
		height=50		
	}
	okButton.isVisible = false
	okButton.isActive = false
		
	restartButton = ui.newButton{
		default = "restartbtn.png",
		over = "restartbtn.png",
		onPress = restartButtonAction,
		width=50,
		height=50
	}
	restartButton.isVisible = false
	restartButton.isActive = false
	
	menuButton = ui.newButton{
		default = "homebtn.png",		
		onPress = menuButtonAction,
		width=50,
		height=50
	}
	menuButton.isVisible = false
	menuButton.isActive = false
	
	popupGroup:insert(okButton)	
	popupGroup:insert(fbButton)
	popupGroup:insert(nextButton)	
	popupGroup:insert(restartButton)		
	popupGroup:insert(menuButton)		
	
	popupGroup.isVisible=false

	-- Fondo oscuro
	shadeRect = display.newRect( 0, 0, 480, 320 )
	shadeRect:setFillColor( 0, 0, 0, 255 )
	shadeRect.alpha = 0
	
	uiGroup:insert(shadeRect)
	uiGroup:insert(popupGroup)
  
end


local function createInfoPanel()	
	 -- Tiempo
	timeText = display.newText( "", 0, 0, "ChubbyCheeks", 26+13 )
	timeText:setTextColor( 255, 255, 0, 180 )	
	timeText.text = totalTime
	timeText.x = 300;	timeText.y = 20+adOffset
	uiGroup:insert(timeText)	
	
	-- Bolas
	ballsText = display.newText( "", 0, 0, "ChubbyCheeks", 26+13 )
	ballsText:setTextColor( 255, 0, 0, 180 )	
	ballsText.text = "0/"..totalBalls
	ballsText.x = 365;	ballsText.y = 20+adOffset
	uiGroup:insert(ballsText)	
	
	-- Score
	scoreText = display.newText( "0", 0, 0, "ChubbyCheeks", 26+13 )
	scoreText:setTextColor(  255, 255, 255, 180 )		
	scoreText.x = 440;	scoreText.y = 20+adOffset
	uiGroup:insert(scoreText)
end

enableNonInteractableObjects = function()
	local obj
	for i=#nonInteractableObjects,1,-1 do	
		obj = nonInteractableObjects[i]
		obj.alpha = 1
		if obj.disableTween then transition.cancel( obj.disableTween ); end
	end
	if nonIteractableTimer then timer.cancel( nonIteractableTimer ); end
end


disableNonInteractableObjects = function()
	local function changeObjectsAlpha()
		local obj
		for i=#nonInteractableObjects,1,-1 do	
			obj = nonInteractableObjects[i]
			--obj.alpha = 0.5
			obj.disableTween = transition.to( obj, { time=500, alpha=0.5 } )
		end
	end
	
	nonIteractableTimer = timer.performWithDelay( 200, changeObjectsAlpha , 1)
end


local function calculateDelta( touch1, touch2 )
        local dx = touch1.x - touch2.x
        local dy = touch1.y - touch2.y
        return dx, dy
end

local function processSwipe(event)
	--print ("swipe",swipeTouchId,event.id,event.phase )
	
	local eventId = event.id	
	local phase = event.phase
	
	--print ("swipe numTotalTouches",mt_numTotalTouches)
	
	if isPopup or draggedObject or mt_numTotalTouches==2 or disableSwipeThrowingBall then
		swipeTouchId=nil 
		
		if phase=="ended" then
			-- Cuando se lanza una bola se desactiva el swipe mediante la vble disableSwipeThrowingBall=true
			-- Cuando suelto el dedo el evento que se dispoara es el de processSwipe porque
			-- se elimina el listener de la bola. Por lo tanto es aqui cuando vuelvo a activar 
			-- el desplazamient de la pantalla
			disableSwipeThrowingBall=false
			canDrag=true
		end
		return true
	end
	
	if phase=="began" and mt_numTotalTouches==1 then
			swipeThPassed=false
			swipeTouchId=eventId
			startCurrentXScreen=currentXScreen
			startCurrentYScreen=currentYScreen
			firstTouch=event
			if swipeTimer~=nil then
				timer.cancel(swipeTimer)
				swipeTimer=nil
			end
			swipeForceX=0
			swipeForceY=0

			-- Si se toca la pantalla con un dedo se para el movimiento
			if swipeTimer~=nil then
				timer.cancel(swipeTimer)
				swipeTimer=nil
			end
	elseif phase=="moved" and eventId==swipeTouchId and mt_numTotalTouches==1 then
		--print ("swipe moved")
		if swipeThPassed==false then
			local dx,dy = calculateDelta(firstTouch,event)
			local d = math.sqrt( dx*dx + dy*dy )
     		if d > 20 then
				swipeThPassed=true
				thDx = dx
				thDy = dy
			end
		end
		
		if swipeThPassed==true then
			canDrag=false
		
			swipeForceX = (firstTouch.x-event.x)/(480*5)
			swipeForceY = (firstTouch.y-event.y)/(320*5)
			--print ("sw",swipeForceX,swipeForceY)
			
			firstTouch=event
				
			local deltaX = (event.xStart - event.x - thDx)/(480*1)
			local deltaY = (event.yStart - event.y - thDy)/(320*1)
		
			--print ("dx",deltaX,event.xStart - event.x, currentXScreen, currentXScreen+deltaX*zoom, event.xStart, event.x)
			--print ("dy",deltaY,event.yStart - event.y, currentXYcreen, currentYScreen+deltaY*zoom, event.yStart, event.y)
		
			currentXScreen = startCurrentXScreen+deltaX
			currentYScreen = startCurrentYScreen+deltaY
		
			if currentXScreen>(xScreens*zoom) then				
				currentXScreen=xScreens*zoom
			end
		
			if (currentXScreen<1) then
				currentXScreen=1
			end
		
			if currentYScreen>(yScreens*zoom) then
				currentYScreen=yScreens*zoom
			end
		
			if (currentYScreen<1) then
				currentYScreen=1
			end
		
			if (deltaX~=0 or deltaY~=0) then
				scenario.x=-((480))*(currentXScreen-1); scenario.y=-((320))*(currentYScreen-1)+offsetY
				backGroup.x=-((480-250))*(currentXScreen-1);backGroup.y=-((320))*(currentYScreen-1)+offsetY
			end
		end
	elseif phase=="ended" and eventId==swipeTouchId  then		
		--print ("swipe ended")
		swipeTouchId=nil
		canDrag=true
		swipeThPassed=false

		local function moveScreen()
			currentXScreen = currentXScreen+swipeForceX
			currentYScreen = currentYScreen+swipeForceY
	
			if currentXScreen>(xScreens*zoom) then				
				currentXScreen=xScreens*zoom
				swipeForceX=0
			end
	
			if (currentXScreen<1) then
				currentXScreen=1
				swipeForceX=0
			end
	
			if currentYScreen>(yScreens*zoom) then
				currentYScreen=yScreens*zoom
				swipeForceY=0
			end
	
			if (currentYScreen<1) then
				currentYScreen=1
				swipeForceY=0
			end

			scenario.x=-((480))*(currentXScreen-1); scenario.y=-((320))*(currentYScreen-1)+offsetY
			backGroup.x=-((480-250))*(currentXScreen-1);backGroup.y=-((320))*(currentYScreen-1)+offsetY
	
			if swipeForceX~=0 or swipeForceY~=0 then
				swipeTimer = timer.performWithDelay( 15, moveScreen, 1 )
			end
		end

		if swipeForceX>1 or swipeForceX<1 or swipeForceY>1 or swipeForceY<1 then
			swipeTimer = timer.performWithDelay( 15, moveScreen, 1 )
		end
	end
end



-- mt_previousTouches
-- mt_numPreviousTouches
-- mt_firstTouch=false
-- mt_distance

-- mt_touch1
-- mt_touch2
-- mt_newDistance
-- mt_numTotalTouches
-- mt_swipeTouchId


local function processMultitouch(event)
	---print ("MT Entry",event.id,event.phase)
	local result = true
	local phase = event.phase
	local id = event.id
	
	if draggedObject~=nil then
		-- Si estoy arrastrando un objeto no permito multitouch
		return true
	end
	
	---print ("Total entry:",mt_numTotalTouches)
	---if (mt_touch1~=nil) then print ("MT entry toque1",mt_touch1.id); end
	---if (mt_touch2~=nil) then print ("MT entry toque2",mt_touch2.id); end

	if "began" == phase then
	    if mt_touch1==nil then
			-- Se trata del primer toque
	        mt_touch1 = event
			mt_numTotalTouches = 1
			---print ("MT primer toque. Toque1:",mt_touch1.id)
	     elseif mt_touch2==nil then
			-- El primer toque está establecido pero el segundo no, compruebo si es uno nuevo
			if mt_touch1.id~=id then
				-- Se trata de un toque nuevo => el segundo
				mt_touch2=event
				mt_numTotalTouches = 2
				canDrag=false
			
				local dx,dy = calculateDelta( mt_touch1, mt_touch2 )
           		local d = math.sqrt( dx*dx + dy*dy )
	        	mt_distance = d
				
				mt_zoom=currentZoom
				
				---print ("MT segundo toque. Toque1:",mt_touch1.id," Toque2:",mt_touch2.id,"d=",mt_distance,"longtouch",mt_longTouch)
			end
		 else
			-- Toque nuevo pero ambos toques estan ya establecidos
			---print ("MT Ignoro")
			return true
	     end
	elseif "moved" == phase then		
		if mt_numTotalTouches==1 then
			-- Solo hay un toque y lo estoy moviendo
			mt_touch1=event
		elseif mt_numTotalTouches==2 then
			-- Hay dos toques largos y estoy moviedo uno => Zoom
			if mt_touch1.id==id then 
				-- Estoy moviendo el primer toque
				---print("Moviendo el primer toque")
				mt_touch1=event
			elseif mt_touch2.id==id then 
				-- Estoy moviendo el segundo toque
				---print("Moviendo el segundo toque")
				mt_touch2=event
			else
				print ("ERROR1!!!!!!!!!!!!!!!!")
			end
			
			-- Recalculo la nueva distancia
			local dx,dy = calculateDelta( mt_touch1, mt_touch2 )
           	mt_newDistance = math.sqrt( dx*dx + dy*dy )
			
			--local scale = mt_newDistance / mt_distance
			local scale = (400-(mt_distance-mt_newDistance))/400
			
			---print ("Dist orig",mt_distance,"New dist",mt_newDistance,"scale",scale)
			---print ("Antes norm. Origzoom",mt_zoom,"newzoom",currentZoom)
			
			local newZoom = mt_zoom*scale
			
			if math.abs(newZoom-currentZoom)>0.01 then	
				currentZoom=newZoom
				
				-- Aplico el zoom
				local max = xScreens>yScreens and xScreens or yScreens
	
				if currentZoom*max<1 then
					currentZoom=1/max
					mt_zoom=currentZoom					
				end
			
				if currentZoom>2 then
					currentZoom=2
					mt_zoom=currentZoom						
				end
		
				---print ("Despues norm. Origzoom",mt_zoom,"newzoom",currentZoom)
				applyZoom(currentZoom)	
			end
		end
	elseif "ended" == phase or "cancelled" == phase then
		if mt_numTotalTouches==1 then
			-- Solo hay un toque y lo he quitado => reset
            mt_distance = nil
			mt_touch1=nil
			mt_touch2=nil
			mt_newDistance=nil
			canDrag=true
			mt_numTotalTouches=0
		elseif mt_numTotalTouches==2 then
			-- Hay dos toques y estoy quitando uno
			if mt_touch1.id==id then
				-- Quito el primer toque
				mt_touch1=mt_touch2
				mt_touch2=nil
			elseif mt_touch2.id==id then
				-- Quito el segundo toque
				mt_touch2=nil
			else
				print ("ERROR2!!!!!!!!!!!!!!!!")
			end
			mt_distance = nil
			canDrag=true
			mt_distance = nil
			mt_numTotalTouches=1
		else
			-- Ignoro este caso. Puede darse cuando suelto un drag => se activa el evento ended pero
			-- el begin no se proceso porque esta dragged			
		end
				
	end
	
	---print ("Total exit:",mt_numTotalTouches)
	---if (mt_touch1~=nil) then print ("MT exit toque1",mt_touch1.id); end
	---if (mt_touch2~=nil) then print ("MT exit toque2",mt_touch2.id); end
	
end


onScreenTouch = function( event )
	processMultitouch(event)
	processSwipe(event)
end

getCeilingY=function()
	local aux
	if yScreens*currentZoom>1 then
		aux=0
	else
		aux = -(1-yScreens*currentZoom)*320-offsetY*currentZoom
	end
	return aux-40
end

function checkOutLimits()
	for i = middleGroup.numChildren,1,-1 do
		local o = middleGroup[i]
		
		if (o.isBodyActive and o~=draggedObject) then
			
			if (o.x<leftMargin or o.x>rightMargin or o.y<topMargin or o.y>bottonMargin) then
				if (o.name=="Ball" and o==currentBall) then
					-- Elimino el timer que pinta el rastro en el caso de que el objeto sea destruido porque se sale de limites
					timer.cancel(dotTimer)
				end
	
				-- Si el objeto se sale de los limites se relanza desde arriba salvo que 
				-- sea una ball en cuyo caso se destruye				
				if o.name=="Ball" then
					o:removeEventListener( "touch", o )
					o:destroy()
				else
					o.x=150
					o.y=getCeilingY()
					
					o:setLinearVelocity( 0, 0 )
					o.angularVelocity = 0	
					o.rotation=0			
				end
				
			end
		end
	end
end

local function hidePopupButtons()
	fbButton.isVisible=false
	nextButton.isVisible=false
	okButton.isVisible=false
	restartButton.isVisible=false
	menuButton.isVisible=false	
end

-- El tamaño de los botones debe ser 50x50
showMessage = function(message)	
	shadeRect.alpha=0
	transition.to( shadeRect, { time=200, alpha=0.65 } )

	-- Pinto los botones
	local buttons = message.buttons
	local buttonsCount = #buttons
	
	local x = (buttonsCount-1)*(-50)+240
  
  -- Oculto todos los botones
  hidePopupButtons()
  -- Activo los botones segun se especifique
	for i = 1,buttonsCount,1 do
		local button = buttons[i]
		button.x=x
		button.y=85+160
		button.isVisible = true
		button.isActive = true
		x = x + 50*2
	end
	
	-- Pinto el mensaje
	message.isVisible=true
	popupGroup:insert(message)
	popupGroup.body=message
	message.y=83
	popupGroup.alpha=0
	popupGroup.isVisible=true
	transition.to( popupGroup, { time=200, alpha=1 } )		
end

drawText = function(text, size, x , y, r,g,b, group)
	local text = display.newText( text, 0, 0, "ChubbyCheeks", size+13 )
	text.xScale = 0.5; text.yScale = 0.5	--> for clear retina display text
	text.x=(text.contentWidth * 0.5)+x;text.y=y
	text:setTextColor(r, g, b)	
	group:insert(text)
	return text
end



local function nextLevel()
	if extraLevelsMode==true then
		if level==extraLevelsCount then
			director:changeScene("levelsel","crossfade")
		else
			currentLevel = "elevel"..(level+1)
			director:changeScene("loadlevel","crossfade")
		end
	else
		if level==5 and isBlockLocked(2) or level==10 and isBlockLocked(3) or level==15 and isBlockLocked(4) then
			director:changeScene("levelsel","crossfade")
		else
			currentLevel = "level"..(level+1)
			director:changeScene("loadlevel","crossfade")
		end
	end
end

-- El juego se completa cuando se pasan todos los niveles extras
-- y todos los niveles disponibles (free/paid)
local function isGameCompleted() 
	local completed=true
	
	if freeMode then
		count=freeLevelsCount
	else
		count=levelsCount
	end
		
	for i=1,count,1 do
		if mainScores[i]==0 then
			completed=false
			break
		end
	end
	for i=1,extraLevelsCount,1 do
		if extraScores[i]==0 then
			completed=false
			break
		end
	end
		
	return completed
end

local function isCurrentBlockCompleted()
	local aux = getCurrentBlock()-1
	local completed=true
	
	for i=aux*5+1,aux*5+5,1 do
		if mainScores[i]<=0 then
			completed=false
			break
		end	
	end
	
	return completed
end

function getBlockScore(id)
	local aux = id-1
	local sum=0
	
	for i=aux*5+1,aux*5+5,1 do
		if mainScores[i]>0 then
			sum=sum+mainScores[i]
		end	
	end
	
	return sum
end

function isBlockCompleted(id)
	local aux = id-1
	local completed=true
	
	for i=aux*5+1,aux*5+5,1 do
		if mainScores[i]<=0 then
			completed=false
			break
		end	
	end
	
	return completed
end

unlockAchievement = function(id)
	print("Unlocking achievement",id)
	gameNetwork.request("unlockAchievement",id)
end

-- Highscore
local function setHighscoreGameCenter(currentBlock)
	
	-- Highscore del bloque
	local aux = currentBlock-1
	if debug then print ("scoreGameNetwork",aux); end
	local blockSum = 0
	for i=aux*5+1,aux*5+5,1 do
		if debug then print ("sc",i,mainScores[i]); end
		blockSum=blockSum+mainScores[i]		
	end
	if debug then print ("scoreGameNetwork Block",openFeintLeaderboardIds[currentBlock], blockSum); end
	gameNetwork.request("setHighScore", { leaderboardID=openFeintLeaderboardIds[currentBlock], score=blockSum, displayText=blockSum.." points" } )		

	if not freeMode then
		-- Total Score
		local totalScore=0
		for i=1,levelsCount,1 do
			if debug then print ("tot sc",i,mainScores[i]); end
			totalScore=totalScore+mainScores[i]		
		end
		if debug then print ("scoreGameNetwork Total",openFeintTotalScoreId, totalScore); end
		gameNetwork.request("setHighScore", { leaderboardID=openFeintTotalScoreId, score=totalScore, displayText=totalScore.." points" } )		
	end
end

drawTextCentered = function(text, size, y, r,g,b, group, offsetX)
	if offsetX==nil then
		offsetX=0
	end
	
	local textObject = display.newText( text, 0, 0, "ChubbyCheeks", size+13 )
	
	textObject:setReferencePoint(display.CenterReferencePoint);
	
	textObject.xScale = 0.5; textObject.yScale = 0.5	--> for clear retina display text
	textObject:setTextColor(r, g, b)
	textObject.x=240+offsetX	
	textObject.y=y
	
	group:insert( textObject )
end

local function showResults()	
	local messageGroup = display.newGroup()
	
	if count<goalBalls then
		-- You Fail
		play(failSound)
		
		-- Score
		drawTextCentered(msgs.get(10),48,30,255,0,0,messageGroup)
		
		local sadApple = display.newImageRect("apple_sad.png",76,76)
		sadApple.x=240;sadApple.y=90
		messageGroup:insert(sadApple)
		
		messageGroup.buttons = {menuButton, restartButton}
	else
		-- Completado el nivel
		if scores[level]==0 then
			-- Lo pongo provisionalmente a 1 para que isGameCompleted pueda detectar
			-- que todos los niveles han acabado
			scores[level]=1
		end
		
		if isGameCompleted() then
			-- Game completed
			play(successSound)
			drawTextCentered(msgs.get(39),48,25,0,255,0,messageGroup,-70)
			
			if freeMode then
				drawTextCentered(msgs.get(41),48,55,0,255,0,messageGroup,-70)
			else
				drawTextCentered(msgs.get(40),48,55,0,255,0,messageGroup,-70)
			end
			
			local happyApple = display.newImageRect("apple_happy.png",76,76)
			happyApple.x=330;happyApple.y=50
			happyApple.scale=0.5
			messageGroup:insert(happyApple)
		
			if score>scores[level] then
				scores[level]=score
				saveScores()
				drawTextCentered(msgs.get(13),48,90,255,255,255,messageGroup,-70)	
				drawTextCentered(score,48,120,120,100,255,messageGroup,-70)	
			else
				drawTextCentered(msgs.get(12)..score,48,90,255,255,255,messageGroup,-70)
				drawTextCentered (msgs.get(9)..scores[level],48,120,255,255,255,messageGroup,-70)			
			end		
				
			nextButtonAction=nextLevel
			if extraLevelsMode then
				messageGroup.buttons = {menuButton}
			else
				messageGroup.buttons = {menuButton, fbButton}
			end
		else
			-- You Win
			play(successSound)
			drawTextCentered(msgs.get(11),48,30,0,255,0,messageGroup,-70)
		
			local happyApple = display.newImageRect("apple_happy.png",76,76)
			happyApple.x=330;happyApple.y=50
			happyApple.scale=0.5
			messageGroup:insert(happyApple)
		
			if score>scores[level] then
				scores[level]=score
				saveScores()
				drawTextCentered(msgs.get(13),48,70,255,255,255,messageGroup,-70)
				drawTextCentered(score,48,110,255,255,0,messageGroup,-70)
							
			else
				drawTextCentered(msgs.get(12)..score,48,70,255,255,255,messageGroup,-70)
				drawTextCentered(msgs.get(9)..scores[level],48,100,255,255,255,messageGroup,-70)			
			end		
				
			nextButtonAction=nextLevel

			if extraLevelsMode then
				messageGroup.buttons = {nextButton,menuButton}
			else
				messageGroup.buttons = {nextButton,menuButton, fbButton}
			end
		end
		
		-- Debloqueo logros en OpenFeint y Game Center si el bloque está completo y estoy jugando en modo normal (no extralevels)
		-- Puntuo en el bloque siempre que acabe un nivel
		if extraLevelsMode==false then
			local currentBlock = getCurrentBlock()
			
			if isCurrentBlockCompleted() then				
				-- Achievement de fin de bloque / juego
				unlockAchievement(OF_BlockAchivementIds[currentBlock])
			end

			setHighscoreGameCenter(currentBlock)			
		end		
	end

	messageGroup.isVisible=false	
	showMessage(messageGroup)
end

local function scoreTimeAndShowResults()	
	local decreaserTimer
	local gotPoints = leftTime*10
	
	local tic = 0
	
	local delta = math.floor(leftTime/50)
	
	if delta<1 then 
		delta=1
	end
	
	local function decreaseLeftTime()				
		if tic == 1 then
			play (clackSound)
			tic=0
		else 
			tic=tic+1
		end
		
		leftTime=leftTime-delta
		
		if leftTime<=0 then
			leftTime=0
			timer.cancel(decreaserTimer)
			timer.performWithDelay( 1500, function() showResults();end, 1 )				
			showPoints(gotPoints,280,17+adOffset,0,40,1500,uiGroup,0.5,2)
			score = score+gotPoints
			scoreText.text = score
			timeText.isVisible=false
			play ( poofSound )
		end
		timeText.text=leftTime	
		
	end
	
	decreaserTimer = timer.performWithDelay( 50, decreaseLeftTime, 0 )
end


gameOver = function(silentPoof) 
	if playing then
		if onGameOver~=nil then
			onGameOver()
		end
		-- Asi evito que se llame a este metodo concurrentemente desde el boton X
		-- y el detector de fin de juego
		
		if freeMode then
			removeAd(0)
		end
		
		if nextBall~=nil then 
			nextBall:removeEventListener( "touch", pioneerAction )
		end
		Runtime:removeEventListener( "touch", onScreenTouch )
		stopAmbientSound()

		playing=false
		removeBalls(silentPoof)
		if swipeTimer then timer.cancel( swipeTimer ); end
		
		-- Desactivo los botones del juego
		disableButtons()
		
		if count>=goalBalls then
			scoreTimeAndShowResults()
		else
			showResults()
		end		
		
		--if count>=goalBalls and onEndLevel~=nil then
		if onEndLevel~=nil then
			-- Paso parametros al evento para que conozca como ha acabado el nivel
			-- por ejemplo para asignar achievements desde cada nivel
			onEndLevel( {totalTime-leftTime, count} )
		end
	end
end

local function start()
  if debug then
	--physics.setDrawMode( "hybrid" )
	--physics.setDrawMode( "debug" )
  end
  
	--- Ads
	if freeMode then	
		displayAd(0)
	end

	physics.start()
		
	playing=true
	endButton.isVisible=true
	
	if debug then
	  zoominButton.isVisible=true	
	  zoomoutButton.isVisible=true	
	end
	
	playAmbientSound()
	
	nextBallTimer = timer.performWithDelay( 2000, function()createNextBall();end, 1 )
	Runtime:addEventListener( "touch", onScreenTouch )
end

local function showLevelInfo()
	local messageGroup
	
	local function hideMessage()
		if messageGroup~=nil then
			transition.to( shadeRect, { time=200, alpha=0 } )
			transition.to( popupGroup, { time=200, alpha=0, onComplete=function()start();end } )		
			messageGroup.buttons=nil
			messageGroup:removeSelf()		
			isPopup=false
			messageGroup=nil
		end	
	end

	local function levelInfo()
		messageGroup = display.newGroup()
		if extraLevelsMode then
			drawTextCentered(msgs.get(58).." "..level,56,27,0,255,255,messageGroup)
		else
			drawTextCentered(msgs.get(4).." "..level,56,27,0,255,255,messageGroup)
		end
		
		drawTextCentered(levelMessage1,39,60,255,255,255,messageGroup)
		drawTextCentered(levelMessage2,39,90,255,255,255,messageGroup)
		drawTextCentered(msgs.get(9)..scores[level],39,120,255,255,255,messageGroup)
		
		okButtonAction = hideMessage
		messageGroup.buttons = {okButton}
		return messageGroup
	end
	
	disableButtons()	
	showMessage(levelInfo())
end

function controlTime()
	currentFrames = currentFrames + 1
				
	if currentFrames>framesPerSec then
		leftTime = leftTime-1
		timeText.text=leftTime
		currentFrames=0
		if (leftTime==0) then
			gameOver(false)
		end
	end
end

local function initVars ()	
	disableSwipeThrowingBall=false
		
	if extraLevelsMode then
		scores=extraScores
	else
		scores=mainScores
	end
	
	if freeMode then
		adOffset=50
	else
		adOffset=0
	end
	
	system.activate( "multitouch" )
	mt_touch1=nil
	mt_touch2=nil
	mt_newDistance=nil
	mt_numTotalTouches=0
	
	--[[
	local simuTouch1={}
	simuTouch1.x=0
	simuTouch1.y=0
	simuTouch1.id=1
	mt_touch1=simuTouch1
	mt_numTotalTouches=1
	--]]
	
	--------
	
	mt_distance=0
	swipeTouchId=nil
	offsetY=0
	swipeForce=0
	canDrag=true
	sentToFacebook=false
	stopTry=0
	nonInteractableObjects={}
	dragableObjs={}
	score=0
	isPopup=false
	falling=false
	currentZoom=1
	zoom=1
 	count = 0
	currentFrames=0
	thrownBalls=0
	currentXScreen=1
	currentYScreen=1

	leftTime=totalTime
	leftMargin = -100
	rightMargin=xScreens*480+100
	bottonMargin=yScreens*320
	topMargin=-200

	trailGroup = display.newGroup()
	
	pause = true
	draggedObject=nil
	
	createStaticObjects()
	createUI()
	createInfoPanel()

	Runtime:addEventListener( "collision", onCollision )
	
	scenario:insert(middleGroup)
	scenario:insert(frontGroup)
	scenario:insert(trailGroup)
	levelGroup:insert(backGroup)
	levelGroup:insert(scenario)
	levelGroup:insert(uiGroup)
		
	checkOutLimitsTimer = timer.performWithDelay( 2000, checkOutLimits, 0 )
	
	managedObjects.isActive=true
	
	playing=false
	
end

applyZoom = function(_zoom)
	
	local factor = _zoom/zoom

	currentXScreen = currentXScreen*factor
	currentYScreen = currentYScreen*factor

	print ("zoom",currentXScreen,currentYScreen,_zoom)

	if currentXScreen>(xScreens*2*_zoom-1) then				
		currentXScreen=xScreens*2*_zoom-1
	end
	
	if currentYScreen>(yScreens*2*_zoom-1) then
		currentYScreen=yScreens*2*_zoom-1
	end
	
	local scenarieX
	local backX
	
	if currentXScreen<1 then 
		scenarieX=0
		backX=0
	else
		scenarieX = -((480))*(currentXScreen-1)
		backX = -((480-250))*(currentXScreen-1)
	end
	
	local scenarieY
	local backY
	
	if currentYScreen<1 then 
		scenarieY=0
		backY=0
	else
		scenarieY = -((320))*(currentYScreen-1)
		backY = -((320))*(currentYScreen-1)
	end

	if yScreens*_zoom < 1 then
		offsetY = (1-yScreens*_zoom)*(320/1.3)
	else
		offsetY=0
	end

	scenario.x=scenarieX
	scenario.y=scenarieY+offsetY
	scenario.xScale=_zoom
	scenario.yScale=_zoom
	
	backGroup.x=backX
	backGroup.y=scenarieY+offsetY
	backGroup.xScale=_zoom
	backGroup.yScale=_zoom
	
	zoom=_zoom
end

function newLevel(_levelGroup, _backGroup, _middleGroup, _frontGroup, _uiGroup, _popupGroup, _scenario, _xScreens, _yScreens,_totalTime,_totalBalls,_goalBalls,_level, _basketX, _basketY)
	onEndLevel=nil
	onThrowBall=nil
	onCreateNextBall=nil
	onGameOver=nil
	stopMusic()
	physics.start()
	physics.pause()
	levelGroup=_levelGroup
	backGroup=_backGroup
	middleGroup=_middleGroup
	frontGroup=_frontGroup
	uiGroup=_uiGroup
	popupGroup=_popupGroup
	scenario=_scenario
	
	xScreens=_xScreens;yScreens=_yScreens;totalTime=_totalTime;totalBalls=_totalBalls;goalBalls=_goalBalls
	basketX=_basketX;basketY=_basketY
	level=_level;

	levelMessage1=msgs.get(5)..goalBalls..msgs.get(6)..totalBalls
	levelMessage2=msgs.get(7)..totalTime..msgs.get(8)
	
	-----------------------------------
	-- Initiate variables
	-----------------------------------
	initVars()
	
	showLevelInfo()
end

function removeManagedImages(group)
	for i = group.numChildren,1,-1 do
		local o = group[i]
		if (o.isManagedImage) then
			o:destroy()
		end
	end
end

function setNonInteractable(obj)
	obj.isNonInteractable=true
	obj.preCollision = onNonIteractablePreCollision
	obj:addEventListener( "preCollision", obj )
	table.insert(nonInteractableObjects,obj)
end

function setDragable(obj)
	obj.isDraggable=true
	obj:addEventListener( "touch", startDrag )
	table.insert(dragableObjs,obj)
end

local function clearDragableObjs()
	for i = #dragableObjs,1,-1 do
		local obj = dragableObjs[i]
		obj:removeEventListener( "touch", startDrag )
		table.remove(dragableObjs,i)
	end
end

removeDragableObj = function(obj)
	for i = #dragableObjs,1,-1 do
		if dragableObjs[i]==obj then
			obj:removeEventListener( "touch", startDrag )
			table.remove(dragableObjs,i)
			break
		end
	end
end

local function clearNonInteractableObjs()
	for i = #nonInteractableObjects,1,-1 do
		local obj=nonInteractableObjects[i]
		obj:removeEventListener( "preCollision", obj )
		if obj.disableTween then transition.cancel( obj.disableTween ); end
		table.remove(dragableObjs,i)
	end
end


local function clearTable(objs)
	for i = #objs,1,-1 do
		table.remove(objs,i)
	end
end

function clean()
	if debug then 
		print ("Cleaning")
	end
	
	--removeAd(0)
	
	currentBall=nil
	if nextBall~=nil then
		nextBall:removeEventListener( "touch", pioneerAction )
		nextBall:destroy()
		nextBall=nil
	end
	
	clearDragableObjs()
	clearNonInteractableObjs()
	
	Runtime:removeEventListener( "touch", onScreenTouch )
	Runtime:removeEventListener( "collision", onCollision )
	
	if endPlayDetectorTimer then timer.cancel( endPlayDetectorTimer ); end
	
	if swipeTimer then timer.cancel( swipeTimer ); end
	if dotTimer then timer.cancel( dotTimer ); end
	if checkOutLimitsTimer then timer.cancel( checkOutLimitsTimer ); end
	if nextBallTimer then timer.cancel( nextBallTimer ); end
	if nonIteractableTimer then timer.cancel( nonIteractableTimer ); end	

	if swipeTween then transition.cancel( swipeTween ); end
	if nextBallTween then transition.cancel( nextBallTween ); end
	--if poofTween then transition.cancel( poofTween ); end
	
	-- Elimino los objetos dinamicos
	removeManagedImages(middleGroup)
	physics.stop()
	
	-- collect garbage
    collectgarbage( "collect" )   
    if debug then
    	print( "memUsage",collectgarbage( "count" ))
    	print( "textureMemoryUsed", system.getInfo( "textureMemoryUsed" ) )
	end
end

-- Contempla hasta 100 niveles
local saveMainScores = function( )
	local path = system.pathForFile( "scores.data", system.DocumentsDirectory )
	
	-- io.open opens a file at path. returns nil if no file found
	local file = io.open( path, "w" )
	if file then
	   for i=1,100,1 do
		   local value = mainScores[i]
		   
		   if value==nil then
		   	value=0
		   end
		   
		   mainScores[i] = value -- Para inicializarlo la primera vez antes de que exista el fichero
		
		   file:write(value.."\n") -- score
	   end
	   
	   io.close( file )
	end
end

local loadMainScores = function( )
	local path = system.pathForFile( "scores.data", system.DocumentsDirectory )
	
	-- io.open opens a file at path. returns nil if no file found
	local file = io.open( path, "r" )
	
	if file then
		for i=1,100,1 do
			local score = file:read( "*line" )
	 		mainScores[i]=tonumber(score)
	 	end
   		io.close( file )
	else
		saveMainScores()
	end
	
	return mainScores
end

-- Contempla hasta 100 niveles
local saveExtraScores = function( )
	local path = system.pathForFile( "extrascores.data", system.DocumentsDirectory )
	
	-- io.open opens a file at path. returns nil if no file found
	local file = io.open( path, "w" )
	if file then
		for i=1,100,1 do
		   local value = extraScores[i]

		   if value==nil then
		   	value=0
		   end

		   extraScores[i] = value -- Para inicializarlo la primera vez antes de que exista el fichero

		   file:write(value.."\n") -- score
	   	end
	   
	   io.close( file )
	end
end

local loadExtraScores = function( )
	local path = system.pathForFile( "extrascores.data", system.DocumentsDirectory )
	
	-- io.open opens a file at path. returns nil if no file found
	local file = io.open( path, "r" )
	
	if file then
		for i=1,100,1 do
			local score = file:read( "*line" )
	 		extraScores[i]=tonumber(score)
	 	end
   		io.close( file )
	else
		saveExtraScores()
	end
	
	return extraScores
end


loadScores = function()
	loadMainScores()
	loadExtraScores()
end

saveScores = function()
	saveMainScores()
	saveExtraScores()
end

loadSettings = function( )
	local path = system.pathForFile( "cfg.data", system.DocumentsDirectory )
	
	-- io.open opens a file at path. returns nil if no file found
	local file = io.open( path, "r" )
	
	if file then
		local audio = file:read( "*line" )
		
		if audio=="on" then
			audioOn=true
		else
			audioOn=false
		end
		
		language = file:read( "*line" )
		
		local music = file:read( "*line" )
		
		if music=="on" or music==nil then
			musicOn=true
		else
			musicOn=false
		end
		
		local ambient = file:read( "*line" )
		
		if ambient=="on" or ambient==nil then
			ambientOn=true
		else
			ambientOn=false
		end

		execCount = file:read( "*line" )
		if execCount==nil or execCount==0 then
			execCount=1
		else
			execCount=execCount+1
		end
		
		gnEnabled = file:read( "*line" )
		if gnEnabled=="yes" then
			gnEnabled=true
		else
			gnEnabled=false
		end
		
		io.close( file )
	end
	
	saveSettings()
	
	return scores
end

saveSettings = function( )
	local path = system.pathForFile( "cfg.data", system.DocumentsDirectory )
	
	-- io.open opens a file at path. returns nil if no file found
	local file = io.open( path, "w" )
	if file then
		local audio = audioOn and "on" or "off"
		local music = musicOn and "on" or "off"
		local ambient = ambientOn and "on" or "off"		
		local gn = gnEnabled and "yes" or "off"
		
		file:write(audio.."\n")
		file:write(language.."\n")
		file:write(music.."\n")
		file:write(ambient.."\n")
		file:write(execCount.."\n")
		file:write(gn.."\n")
	  	io.close( file )
	end
end

getCurrentBlock = function()
	local aux=math.floor((level-1)/5)+1
	return aux
end

isBlockLocked = function(block)
	local unlocked=true
	for i=(block-2)*5+1,(block-1)*5,1 do
		if mainScores[i]==0 then
			unlocked=false
			break
		end
	end
	
	return not unlocked
end

