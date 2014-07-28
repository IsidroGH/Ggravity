--
-- msgs.lua
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

msgs={}

msgs["1en"]="Audio"
msgs["1sp"]="Sonido"
msgs["2en"]="Language"
msgs["2sp"]="Idioma"
msgs["3en"]="Settings"
msgs["3sp"]="Opciones"
msgs["4en"]="Level"
msgs["4sp"]="Nivel"

msgs["5en"]="Goal: Pick up "
msgs["6en"]=" apples out of "
msgs["7en"]="Time: "
msgs["8en"]=" seconds"

msgs["5sp"]="Objetivo: Recoger "
msgs["6sp"]=" manzanas de "
msgs["7sp"]="Tiempo: "
msgs["8sp"]=" segundos"

msgs["9en"]="Highest Score: "
msgs["9sp"]="Puntuación Máxima: "

msgs["10en"]="You Fail!"
msgs["10sp"]= "¡Fallaste!"

msgs["11en"]= "You Win!"
msgs["11sp"]= "¡Ganaste!"

msgs["12en"]= "Your Score: "
msgs["12sp"]= "Puntos: "

msgs["13en"]= "New Highest Score"
msgs["13sp"]= "Nuevo Récord"

-- HELP

msgs["14en"]="The goal is simple, just make the apples way to the basket using the available objects. Once you are ready, touch the apples to make them fall."
msgs["14sp"]="El objetivo es simple, lleva las manzanas a la cesta usando los objetos disponibles. Para ello, toca las manzanas para hacerlas caer."

msgs["15en"]="You can move the objects by dragging & dropping them. You can also touch them to rotate."
msgs["15sp"]="Puedes mover y arrastrar los objetos. También puedes rotarlos simplemente tocándolos."

msgs["16en"]="You can zoom and scroll the screen."
msgs["16sp"]="Puedes hacer zoom y desplazar la pantalla."

msgs["17en"]="Touch the screen below and then on each object to get a detailed description."
msgs["17sp"]="Toca la pantalla de abajo y después cada objeto para ver una descripción detallada."

msgs["22en"]="The stones will let you fit the inclination and height of other objects."
msgs["22sp"]="Las piedras te permitirán ajustar la inclinación y altura de otros objetos."

msgs["23en"]="Be carefull! The objects can move by the usage and you will have to adjust them again."
msgs["23sp"]="Ten cuidado!, los objetos pueden moverse con el uso y tendrás que volver a ajustarlos."

msgs["24en"]="The slopes will let you guide the apples and build structures."
msgs["24sp"]="Las rampas te permitirán guiar las manzanas y construir estructuras."

msgs["25en"]="The elastic beds will let you change the trajectory of the apples when they fall over them."
msgs["25sp"]="La cama elástica te permitirá cambiar la trayectoria de las manzanas haciéndolas caer encima."

msgs["26en"]="In order to get that, you will have to adjust its inclination over other objects."
msgs["26sp"]="Para ello, tendrás que ajustar su inclinación apoyándolas sobre otros objetos."

msgs["27en"]="Guide an apple through the propellent tube in the indicated direction and it will be ejected."
msgs["27sp"]="Introduce una manzana en el tubo propulsor en la dirección indicada y será lanzada."

msgs["29en"]="The static objects are redish and are part of the scenarie so you can´t move them."
msgs["29sp"]="Los objetos estáticos son de color rojizo y son parte del escenario por lo que no pueden ser movidos."

msgs["31en"]="The dynamic objects are yelowish. You can't drag & drop them although you can move them indirectly by throwing apples over."
msgs["31sp"]="Los objetos dinámicos son amarillentos. No puedes moverlos aunque puedes hacerlo indirectamente lanzando manzanas sobre ellos."

msgs["34sp"]="Bloque Cerrado"
msgs["34en"]="Locked Block"
msgs["35sp"]="Completa antes el bloque anterior"
msgs["35en"]="Complete the previuos one before"

msgs["39en"]="You Completed"
msgs["39sp"]="¡Has Completado"
msgs["40en"]="Ggravity!"
msgs["40sp"]="Ggravity!"
msgs["41en"]="Ggravity Free!"
msgs["41sp"]="Ggravity Free!"

msgs["42en"]="Just scored "
msgs["42sp"]="Acabo de conseguir "
msgs["43en"]=" points in level "
msgs["43sp"]=" puntos en el nivel "
msgs["44en"]=" on Ggravity!"
msgs["44sp"]=" de Ggravity!"
msgs["45en"]="Download Ggravity!"
msgs["45sp"]="¡Descarga Ggravity!"
msgs["46en"]="Use your intelligence to help the apples reach the basket."
msgs["46sp"]="Usa tu inteligencia para llevar las manzanas a la cesta."
msgs["47en"]="Are you smart enough?"
msgs["47sp"]="¿Eres lo suficiente inteligente?"

msgs["54en"]="Music"
msgs["54sp"]="Música"

msgs["55en"]="Touch the following objects to move them or rotate and a description will come up."
msgs["55sp"]="Toca los siguientes objetos para moverlos o rotarlos y aparecerá una breve descripción."

msgs["56en"]="Level Selection"
msgs["56sp"]="Selección de Nivel"

msgs["57en"]="Ambient"
msgs["57sp"]="Ambiente"

msgs["58en"]="Level Extra"
msgs["58sp"]="Nivel Extra"

msgs["59en"]="Play"
msgs["59sp"]="Jugar"

msgs["60en"]="Extra Levels"
msgs["60sp"]="Niveles Extra"

msgs["61en"]="Points:"
msgs["61sp"]="Puntos:"

msgs["62en"]="Block 1 - New York"
msgs["62sp"]="Bloque 1 - Nueva York"

msgs["63en"]="Block 2 - Paris"
msgs["63sp"]="Bloque 2 - Paris"

msgs["64en"]="Block 3 - Rio"
msgs["64sp"]="Bloque 3 - Rio"

msgs["65en"]="Block 4 - Madrid"
msgs["65sp"]="Bloque 4 - Madrid"

msgs["68en"]="Please rate Ggravity and don't worry, you'll see this message only this time."
msgs["68sp"]="Por favor puntúa Ggravity y no te preocupes, sólo esta vez verás este mensaje."

msgs["69en"]="Rate"
msgs["69sp"]="Puntuar"

msgs["70en"]="No, thanks"
msgs["70sp"]="No, gracias"

msgs["71en"]="Remind me later"
msgs["71sp"]="Recuérdamelo después"

msgs["72en"]="Touch the apple to make it falls"
msgs["72sp"]="Toca la manzana para hacerla caer"


function get(id)	
	--print ("->",id,id..game.language,msgs[id..game.language])
	return msgs[id..game.language]
end
