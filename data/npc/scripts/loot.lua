local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)				npcHandler:onCreatureAppear(cid) 			end
function onCreatureDisappear(cid) 			npcHandler:onCreatureDisappear(cid) 			end
function onCreatureSay(cid, type, msg) 			npcHandler:onCreatureSay(cid, type, msg) 		end
function onThink() 					npcHandler:onThink() 					end

-- Sistema Universal de Compra de Loot
-- Este NPC compra TODOS los items del juego

function greetCallback(cid)
	npcHandler:say("Hola " .. getCreatureName(cid) .. "! Te compro CUALQUIER item que tengas. Solo di {trade} para ver que puedo comprarte!", cid)
	return true
end

-- Lista de items comunes con sus precios
-- Este NPC usa una tabla de precios por defecto y calcula precios para items no listados
local shopItems = {
	-- Armors
	["plate armor"] = 400,
	["brass armor"] = 150,
	["chain armor"] = 70,
	["leather armor"] = 12,
	["studded armor"] = 25,
	["scale armor"] = 75,
	["knight armor"] = 5000,
	["golden armor"] = 20000,
	["crown armor"] = 12000,
	["dragon scale mail"] = 40000,
	["magic plate armor"] = 90000,
	["demon armor"] = 200000,
	["dark armor"] = 400,
	
	-- Helmets
	["iron helmet"] = 150,
	["steel helmet"] = 293,
	["brass helmet"] = 30,
	["chain helmet"] = 17,
	["viking helmet"] = 66,
	["warrior helmet"] = 5000,
	["crown helmet"] = 2500,
	["devil helmet"] = 1000,
	["royal helmet"] = 30000,
	["crusader helmet"] = 6000,
	
	-- Legs
	["plate legs"] = 115,
	["brass legs"] = 49,
	["chain legs"] = 25,
	["leather legs"] = 9,
	["knight legs"] = 5000,
	["crown legs"] = 12000,
	["golden legs"] = 30000,
	
	-- Boots
	["leather boots"] = 2,
	["boots of haste"] = 30000,
	["steel boots"] = 40000,
	["golden boots"] = 100000,
	
	-- Shields
	["wooden shield"] = 5,
	["steel shield"] = 80,
	["brass shield"] = 25,
	["plate shield"] = 45,
	["viking shield"] = 85,
	["ancient shield"] = 900,
	["tower shield"] = 8000,
	["dragon shield"] = 4000,
	["demon shield"] = 30000,
	["blessed shield"] = 100000,
	["mastermind shield"] = 50000,
	
	-- Weapons - Swords
	["sword"] = 25,
	["broadsword"] = 50,
	["longsword"] = 50,
	["fire sword"] = 4000,
	["ice rapier"] = 1000,
	["katana"] = 35,
	["two handed sword"] = 450,
	["giant sword"] = 17000,
	["bright sword"] = 6000,
	["magic sword"] = 100000,
	["magic longsword"] = 140000,
	
	-- Weapons - Axes
	["axe"] = 7,
	["battle axe"] = 80,
	["double axe"] = 260,
	["halberd"] = 400,
	["fire axe"] = 8000,
	["dragon lance"] = 9000,
	["guardian halberd"] = 11000,
	["stonecutter axe"] = 90000,
	
	-- Weapons - Clubs
	["club"] = 1,
	["mace"] = 30,
	["morning star"] = 90,
	["battle hammer"] = 120,
	["war hammer"] = 1200,
	["clerical mace"] = 170,
	["skull staff"] = 6000,
	["thunder hammer"] = 90000,
	
	-- Weapons - Distance
	["bow"] = 130,
	["crossbow"] = 160,
	["spear"] = 3,
	["arrow"] = 2,
	["bolt"] = 3,
	
	-- Runes
	["blank rune"] = 10,
	
	-- Valuables
	["gold coin"] = 1,
	["platinum coin"] = 100,
	["crystal coin"] = 10000,
	["small diamond"] = 300,
	["small sapphire"] = 250,
	["small ruby"] = 250,
	["small emerald"] = 250,
	["small amethyst"] = 200,
	["gold nugget"] = 850,
	
	-- Creature Products
	["wolf paw"] = 70,
	["bear paw"] = 100,
	["minotaur leather"] = 80,
	["minotaur horn"] = 75,
	["dragon ham"] = 100,
	["dragon's tail"] = 100,
	["bone"] = 10,
	["turtle shell"] = 90,
	["ape fur"] = 120,
	["demon horn"] = 1000,
	["demon dust"] = 300,
	["vampire dust"] = 100,
	["shadow herb"] = 20,
}

-- Mensaje de ayuda
keywordHandler:addKeyword({'help'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Te compro TODOS los items del juego! Solo abre {trade} y vendeme lo que quieras.'})
keywordHandler:addKeyword({'ayuda'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Te compro TODOS los items del juego! Solo abre {trade} y vendeme lo que quieras.'})

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:addModule(FocusModule:new())
