--
-- utils.lua
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


local function printLine(text,x,y,textSize,textRColor,textGColor,textBColor,group)	
	return drawText (text, x, y,textSize, textRColor,textGColor,textBColor, group)	
end

local function printMultilineText(text,x,y,len,textSize,textRColor,textGColor,textBColor,group)
	local yOrig=y	
	local lastSpace = 0
	local iniLine=1
	local lineLen=0
	local spaceChar = string.byte(" ",1)
	
	local maxWidth=0
	
	for i=1, text:len() do
		--print ("c: ",text:byte(i))
		if text:byte(i)==spaceChar then
			lastSpace=i
		end
		
		lineLen=lineLen+1
		
		--print (i,lineLen,len,iniLine,lastSpace)
		
		if lineLen>len then
			line = text:sub(iniLine,lastSpace)
			local textWidth, textHeight = printLine(line,x,y,textSize,textRColor,textGColor,textBColor,group)
			if textWidth>maxWidth then
				maxWidth=textWidth
			end
			--print ("Linea: ",line,textHeight)
			y=y+textHeight+5

			iniLine=lastSpace+1
			--print ("kkk:",line:len(),":",iniLine)
			lineLen=i-lastSpace+1
		end
		
	end
	
	--print ("x1:",iniLine,text:len())
	
	if iniLine<=text:len() then
		line = text:sub(iniLine,text:len())
		local textWidth, textHeight = printLine(line,x,y,textSize,textRColor,textGColor,textBColor,group)
		if textWidth>maxWidth then
			maxWidth=textWidth
		end
		--print ("Linea*: ",line,textHeight)
		y=y+textHeight
	end
	
	return maxWidth, y-yOrig
end


local function internalCreateMessage(lineLen,textSize,xMargin, yMargin,text,textRColor,textGColor,textBColor,fillRColor,fillGColor,fillBColor,borderSize,borderRColor,borderGColor,borderBColor,group,reference,x,y)
	local msgGroup = display.newGroup()	
	local textGroup = display.newGroup()

	local textWidth, textHeight = printMultilineText(text,xMargin,yMargin,lineLen,textSize, textRColor,textGColor,textBColor, textGroup)

	local box = display.newRoundedRect( msgGroup, 0, 0, textWidth+xMargin*2, textHeight+yMargin*2, 10 ) 
	box.strokeWidth = borderSize
	box:setStrokeColor(borderRColor, borderGColor, borderBColor)
	
	box:setFillColor(fillRColor, fillGColor, fillBColor)

	
	msgGroup:insert(box)
	msgGroup:insert(textGroup)
	group:insert(msgGroup)

	msgGroup.messageHeight=textHeight+yMargin*2
	
	if reference~=nil then		
		msgGroup:setReferencePoint(reference)
	end
	
	if x~=nil and y~=nil then
		msgGroup.x=x
		msgGroup.y=y
	end
	
	return msgGroup
end

local function internalCreateBox(width,height,fillRColor,fillGColor,fillBColor,borderSize,borderRColor,borderGColor,borderBColor,group,reference,x,y)
	local msgGroup = display.newGroup()	
	local bodyGroup = display.newGroup()

	local box = display.newRoundedRect( msgGroup, 0, 0, width, height, 10 ) 
	box.strokeWidth = borderSize
	box:setStrokeColor(borderRColor, borderGColor, borderBColor)
	
	box:setFillColor(fillRColor, fillGColor, fillBColor)

	
	msgGroup:insert(box)
	msgGroup:insert(bodyGroup)
	group:insert(msgGroup)

	if reference~=nil then		
		msgGroup:setReferencePoint(reference)
	end
	
	if x~=nil and y~=nil then
		msgGroup.x=x
		msgGroup.y=y
	end
	
	msgGroup.body=bodyGroup
	
	return msgGroup
end

local function buttonAction(action,button,animation)
	local closure = function(event)
		if event.phase=="began" then
			if animation then 
				button.alpha=0.5
			end
			elseif event.phase=="ended" then
			button.alpha=1
			action()
		end	
	end	
	button.action=closure
	return closure	
end

-- Funciones publicas

function createCustomBox(width,height,messageParams,group, action, animation,reference,x,y)
	local button = internalCreateBox(width,height,messageParams.fillRColor,messageParams.fillGColor,messageParams.fillBColor,messageParams.borderSize,messageParams.borderRColor,messageParams.borderGColor,messageParams.borderBColor,group, reference,x,y)

	if action~=nil then
		button:addEventListener( "touch", buttonAction(action,button,animation) )
	end
	
	return button
end

function removeCustomBox(button)
	if button~=nil then
		button:removeEventListener( "touch", button.action )
	end
end

function createMessage(text,messageParams,group, reference,x,y)
	return internalCreateMessage(messageParams.lineLen,messageParams.textSize,messageParams.xMargin,messageParams.yMargin,text,messageParams.textRColor,messageParams.textGColor,messageParams.textBColor,messageParams.fillRColor,messageParams.fillGColor,messageParams.fillBColor,messageParams.borderSize,messageParams.borderRColor,messageParams.borderGColor,messageParams.borderBColor,group, reference,x,y)
end

function createTextButton(text,messageParams,group, action, animation, reference,x,y)
	local button = utils.createMessage(text,messageParams,group,reference,x,y)

	button:addEventListener( "touch", buttonAction(action,button,animation) )
	
	return button
end

function removeTextButton(button)
	if button~=nil then
		button:removeEventListener( "touch", buttonAction )
	end
end

function drawText(text, x , y, size, r,g,b, group)
	local text = display.newText( text, 0, 0, "ChubbyCheeks", size+13 )
	text.xScale = 0.5; text.yScale = 0.5	--> for clear retina display text
	text.x=(text.contentWidth*0.5)+x
	text.y=(text.contentHeight*0.5)/2+y
	text:setTextColor(r, g, b)	
	group:insert(text)
	return text.contentWidth,text.contentHeight/2
end

function drawTextCentered (text, size, y, r,g,b, group, offsetX)
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

DefaultButtonStyle={}
DefaultButtonStyle.lineLen=40
DefaultButtonStyle.textSize=40
DefaultButtonStyle.xMargin=10
DefaultButtonStyle.yMargin=10
DefaultButtonStyle.textRColor=255
DefaultButtonStyle.textGColor=255
DefaultButtonStyle.textBColor=255
DefaultButtonStyle.fillRColor=0
DefaultButtonStyle.fillGColor=100
DefaultButtonStyle.fillBColor=200
DefaultButtonStyle.borderSize=1
DefaultButtonStyle.borderRColor=255
DefaultButtonStyle.borderGColor=255
DefaultButtonStyle.borderBColor=255

function getDefaultButtonStyle()
	local style={}
	style.lineLen=40
	style.textSize=40
	style.xMargin=10
	style.yMargin=10
	style.textRColor=255
	style.textGColor=255
	style.textBColor=255
	style.fillRColor=0
	style.fillGColor=100
	style.fillBColor=200
	style.borderSize=1
	style.borderRColor=255
	style.borderGColor=255
	style.borderBColor=255
	return style
end

