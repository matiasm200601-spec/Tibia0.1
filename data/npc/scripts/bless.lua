local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)


function onCreatureAppear(cid)				npcHandler:onCreatureAppear(cid) 			end
function onCreatureDisappear(cid) 			npcHandler:onCreatureDisappear(cid) 		end
function onCreatureSay(cid, type, msg) 		npcHandler:onCreatureSay(cid, type, msg) 	end
function onThink() 							npcHandler:onThink() 						end

function greetCallback(cid)
	npcHandler:say('Bienvenido! Puedo darte bendiciones. Di: {first bless}, {second bless}, {third bless}, {fourth bless}, {fifth bless}', cid)
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)

local node1 = keywordHandler:addKeyword({'first bless'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Deseas comprar la primera bendicion por 2000 (mas cantidad segun nivel) de oro? Di {yes} para confirmar.'})
	node1:addChildKeyword({'yes'}, StdModule.bless, {npcHandler = npcHandler, number = 1, premium = true, baseCost = 2000, levelCost = 200, startLevel = 30, endLevel = 120})
	node1:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Muy caro, eh?'})

local node2 = keywordHandler:addKeyword({'second bless'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Deseas comprar la segunda bendicion por 2000 (mas cantidad segun nivel) de oro? Di {yes} para confirmar.'})
	node2:addChildKeyword({'yes'}, StdModule.bless, {npcHandler = npcHandler, number = 2, premium = true, baseCost = 2000, levelCost = 200, startLevel = 30, endLevel = 120})
	node2:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Muy caro, eh?'})

local node3 = keywordHandler:addKeyword({'third bless'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Deseas comprar la tercera bendicion por 2000 (mas cantidad segun nivel) de oro? Di {yes} para confirmar.'})
	node3:addChildKeyword({'yes'}, StdModule.bless, {npcHandler = npcHandler, number = 3, premium = true, baseCost = 2000, levelCost = 200, startLevel = 30, endLevel = 120})
	node3:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Muy caro, eh?'})

local node4 = keywordHandler:addKeyword({'fourth bless'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Deseas comprar la cuarta bendicion por 2000 (mas cantidad segun nivel) de oro? Di {yes} para confirmar.'})
	node4:addChildKeyword({'yes'}, StdModule.bless, {npcHandler = npcHandler, number = 4, premium = true, baseCost = 2000, levelCost = 200, startLevel = 30, endLevel = 120})
	node4:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Muy caro, eh?'})

local node5 = keywordHandler:addKeyword({'fifth bless'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Deseas comprar la quinta bendicion por 2000 (mas cantidad segun nivel) de oro? Di {yes} para confirmar.'})
	node5:addChildKeyword({'yes'}, StdModule.bless, {npcHandler = npcHandler, number = 5, premium = true, baseCost = 2000, levelCost = 200, startLevel = 30, endLevel = 120})
	node5:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, reset = true, text = 'Muy caro, eh?'})

npcHandler:addModule(FocusModule:new())
