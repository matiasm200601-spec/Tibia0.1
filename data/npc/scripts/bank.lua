local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local Topic, count, transferTo_name = {}, {}, {}

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

local function getCount(string)
	local b, e = string:find('%d+')
	return b and e and tonumber(string:sub(b, e)) or -1
end

local function playerExists(name)
	local v, ret = db.getResult("SELECT `name` FROM `players` WHERE `name` = " .. db.escapeString(name) .. ";"), nil
	if v:getID() ~= -1 then
		ret = v:getDataString('name')
	end
	v:free()
	return ret
end

function greetCallback(cid)
	Topic[cid], count[cid], transferTo_name[cid] = 0, 0,0
	-- Mensaje de ayuda en espanol
	npcHandler:say('Bienvenido al banco! Puedes usar: {balance} (consultar saldo), {deposit} (depositar), {withdraw} (retirar), {transfer} (transferir), {change} (cambiar monedas).', cid)
	return true
end

function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	elseif msgcontains(msg, 'balance') then
		npcHandler:say('Tu saldo es ' .. getPlayerBalance(cid) .. ' de oro.', cid)
		Topic[cid] = 0
	elseif msgcontains(msg, 'deposit') and msgcontains(msg, 'all') then
		if getPlayerMoney(cid) > 0 then
			count[cid] = getPlayerMoney(cid)
			npcHandler:say('Realmente deseas depositar ' .. count[cid] .. ' gold?', cid)
			Topic[cid] = 2
		else
			npcHandler:say('Dime cuanto oro deseas depositar.', cid)
			Topic[cid] = 1
		end
	elseif msgcontains(msg, 'deposit') then
		if getCount(msg) == 0 then
			npcHandler:say('You are joking, aren\'t you??', cid)
			Topic[cid] = 0
		elseif getCount(msg) ~= -1 then
			if getPlayerMoney(cid) >= getCount(msg) then
				count[cid] = getCount(msg)
				npcHandler:say('Realmente deseas depositar ' .. count[cid] .. ' gold?', cid)
				Topic[cid] = 2
			else
				npcHandler:say('You do not have enough de oro.', cid)
				Topic[cid] = 0
			end
		else
			npcHandler:say('Dime cuanto oro deseas depositar.', cid)
			Topic[cid] = 1
		end
	elseif Topic[cid] == 1 then
		if getCount(msg) == -1 then
			npcHandler:say('Dime cuanto oro deseas depositar.', cid)
			Topic[cid] = 1
		else
			if getPlayerMoney(cid) >= getCount(msg) then
				count[cid] = getCount(msg)
				npcHandler:say('Realmente deseas depositar ' .. count[cid] .. ' gold?', cid)
				Topic[cid] = 2
			else
				npcHandler:say('You do not have enough de oro.', cid)
				Topic[cid] = 0
			end
		end
	elseif msgcontains(msg, 'yes') and Topic[cid] == 2 then
		if doPlayerRemoveMoney(cid, count[cid]) then
			doPlayerSetBalance(cid, getPlayerBalance(cid) + count[cid])
			npcHandler:say('Muy bien, hemos agregado ' .. count[cid] .. ' de oro a tu saldo. Puedes retirar tu dinero cuando desees.', cid)
		else
			npcHandler:say('I am inconsolable, but it seems you have lost your de oro. I hope you get it back.', cid)
		end
		Topic[cid] = 0
	elseif msgcontains(msg, 'no') and Topic[cid] == 2 then
		npcHandler:say('Como desees. Hay algo mas que pueda hacer por ti?', cid)
		Topic[cid] = 0
	elseif msgcontains(msg, 'withdraw') then
		if getCount(msg) == 0 then
			npcHandler:say('Claro, si no quieres nada no obtienes nada!', cid)
			Topic[cid] = 0
		elseif getCount(msg) ~= -1 then
			if getPlayerBalance(cid) >= getCount(msg) then
				count[cid] = getCount(msg)
				npcHandler:say('Estas seguro que deseas retirar ' .. count[cid] .. ' de oro de tu cuenta bancaria?', cid)
				Topic[cid] = 4
			else
				npcHandler:say('No hay suficiente oro en tu cuenta.', cid)
				Topic[cid] = 0
			end
		else
			npcHandler:say('Dime cuanto oro deseas retirar.', cid)
			Topic[cid] = 3
		end
	elseif Topic[cid] == 3 then
		if getCount(msg) == -1 then
			npcHandler:say('Dime cuanto oro deseas retirar.', cid)
			Topic[cid] = 3
		else
			if getPlayerBalance(cid) >= getCount(msg) then
				count[cid] = getCount(msg)
				npcHandler:say('Estas seguro que deseas retirar ' .. count[cid] .. ' de oro de tu cuenta bancaria?', cid)
				Topic[cid] = 4
			else
				npcHandler:say('No hay suficiente oro en tu cuenta.', cid)
				Topic[cid] = 0
			end
		end
	elseif msgcontains(msg, 'yes') and Topic[cid] == 4 then
		if getPlayerBalance(cid) >= count[cid] then
			doPlayerAddMoney(cid, count[cid])
			doPlayerSetBalance(cid, getPlayerBalance(cid) - count[cid])
			npcHandler:say('Aqui tienes, ' .. count[cid] .. ' de oro. Please let me know if there is something else I can do for you.', cid)
		else
			npcHandler:say('No hay suficiente oro en tu cuenta.', cid)
		end
		Topic[cid] = 0
	elseif msgcontains(msg, 'no') and Topic[cid] == 4 then
		npcHandler:say('El cliente es el rey! Regresa cuando desees retirar tu dinero.', cid)
		Topic[cid] = 0
	elseif msgcontains(msg, 'transfer') then
		if getCount(msg) == 0 then
			npcHandler:say('Piensalo. De acuerdo?', cid)
			Topic[cid] = 0
		elseif getCount(msg) ~= -1 then
			count[cid] = getCount(msg)
			if getPlayerBalance(cid) >= count[cid] then
				npcHandler:say('A quien deseas transferir ' .. count[cid] .. ' de oro?', cid)
				Topic[cid] = 6
			else
				npcHandler:say('No hay suficiente oro en tu cuenta.', cid)
				Topic[cid] = 0
			end
		else
			npcHandler:say('Dime la cantidad de oro que deseas transferir.', cid)
			Topic[cid] = 5
		end
	elseif Topic[cid] == 5 then
		if getCount(msg) == -1 then
			npcHandler:say('Dime la cantidad de oro que deseas transferir.', cid)
			Topic[cid] = 5
		else
			count[cid] = getCount(msg)
			if getPlayerBalance(cid) >= count[cid] then
				npcHandler:say('A quien deseas transferir ' .. count[cid] .. ' de oro?', cid)
				Topic[cid] = 6
			else
				npcHandler:say('No hay suficiente oro en tu cuenta.', cid)
				Topic[cid] = 0
			end
		end
	elseif Topic[cid] == 6 then
		local v = getPlayerByName(msg)
		if getPlayerBalance(cid) >= count[cid] then
			if v then
				transferTo_name[cid] = msg
				npcHandler:say('Realmente deseas transferir ' .. count[cid] .. ' gold to ' .. getPlayerName(v) .. '?', cid)
				Topic[cid] = 7
			elseif playerExists(msg):lower() == msg:lower() then
				transferTo_name[cid] = msg
				npcHandler:say('Realmente deseas transferir ' .. count[cid] .. ' gold to ' .. playerExists(msg) .. '?', cid)
				Topic[cid] = 7
			else
				npcHandler:say('Este jugador no existe.', cid)
				Topic[cid] = 0
			end
		else
			npcHandler:say('No hay suficiente oro en tu cuenta.', cid)
			Topic[cid] = 0
		end
	elseif Topic[cid] == 7 and msgcontains(msg, 'yes') then
		if getPlayerBalance(cid) >= count[cid] then
			local v = getPlayerByName(transferTo_name[cid])
			if v then
				doPlayerSetBalance(cid, getPlayerBalance(cid) - count[cid])
				doPlayerSetBalance(v, getPlayerBalance(v) + count[cid])
				npcHandler:say('Muy bien. Has transferido ' .. count[cid] .. ' gold to ' .. getPlayerName(v) .. '.', cid)
			elseif playerExists(transferTo_name[cid]):lower() == transferTo_name[cid]:lower() then
				doPlayerSetBalance(cid, getPlayerBalance(cid) - count[cid])
				db.executeQuery('UPDATE `players` SET `balance` = `balance` + ' .. count[cid] .. ' WHERE `name` = ' .. db.escapeString(transferTo_name[cid]) .. ' LIMIT 1;')
				npcHandler:say('Muy bien. Has transferido ' .. count[cid] .. ' gold to ' .. playerExists(transferTo_name[cid]) .. '.', cid)
			else
				npcHandler:say('Este jugador no existe.', cid)
			end
		else
			npcHandler:say('No hay suficiente oro en tu cuenta.', cid)
		end
		Topic[cid] = 0
	elseif Topic[cid] == 7 and msgcontains(msg, 'no') then
		npcHandler:say('De acuerdo, hay algo mas que pueda hacer por ti?', cid)
		Topic[cid] = 0
	elseif msgcontains(msg, 'change gold') then
		npcHandler:say('Cuantas platinum coins deseas obtener?', cid)
		Topic[cid] = 8
	elseif Topic[cid] == 8 then
		if getCount(msg) < 1 then
			npcHandler:say('Hmm, puedo ayudarte con algo mas?', cid)
			Topic[cid] = 0
		else
			count[cid] = getCount(msg)
			npcHandler:say('Entonces deseas que cambie ' .. count[cid] * 100 .. ' de tus gold coins por ' .. count[cid] .. ' platinum coins?', cid)
			Topic[cid] = 9
		end
	elseif Topic[cid] == 9 then
		if msgcontains(msg, 'yes') then
			if doPlayerRemoveItem(cid, 2148, count[cid] * 100) then
				npcHandler:say('Aqui tienes.', cid)
				doPlayerAddItem(cid, 2152, count[cid])
			else
				npcHandler:say('Lo siento, no tienes suficientes gold coins.', cid)
			end
		else
			npcHandler:say('Bien, puedo ayudarte con algo mas?', cid)
		end
		Topic[cid] = 0
	elseif msgcontains(msg, 'change platinum') then
		npcHandler:say('Deseas cambiar tus platinum coins por gold o crystal?', cid)
		Topic[cid] = 10
	elseif Topic[cid] == 10 then
		if msgcontains(msg, 'gold') then
			npcHandler:say('Cuantas platinum coins deseas cambiar por gold?', cid)
			Topic[cid] = 11
		elseif msgcontains(msg, 'crystal') then
			npcHandler:say('Cuantas crystal coins deseas obtener?', cid)
			Topic[cid] = 13
		else
			npcHandler:say('Bien, puedo ayudarte con algo mas?', cid)
			Topic[cid] = 0
		end
	elseif Topic[cid] == 11 then
		if getCount(msg) < 1 then
			npcHandler:say('Hmm, puedo ayudarte con algo mas?', cid)
			Topic[cid] = 0
		else
			count[cid] = getCount(msg)
			npcHandler:say('Entonces deseas que cambie ' .. count[cid] .. ' de tus platinum coins por ' .. count[cid] * 100 .. ' gold coins?', cid)
			Topic[cid] = 12
		end
	elseif Topic[cid] == 12 then
		if msgcontains(msg, 'yes') then
			if doPlayerRemoveItem(cid, 2152, count[cid]) then
				npcHandler:say('Aqui tienes.', cid)
				doPlayerAddItem(cid, 2148, count[cid] * 100)
			else
				npcHandler:say('Lo siento, no tienes suficientes platinum coins.', cid)
			end
		else
			npcHandler:say('Bien, puedo ayudarte con algo mas?', cid)
		end
		Topic[cid] = 0
	elseif Topic[cid] == 13 then
		if getCount(msg) < 1 then
			npcHandler:say('Hmm, puedo ayudarte con algo mas?', cid)
			Topic[cid] = 0
		else
			count[cid] = getCount(msg)
			npcHandler:say('Entonces deseas que cambie ' .. count[cid] * 100 .. ' de tus platinum coins por ' .. count[cid] .. ' crystal coins?', cid)
			Topic[cid] = 14
		end
	elseif Topic[cid] == 14 then
		if msgcontains(msg, 'yes') then
			if doPlayerRemoveItem(cid, 2152, count[cid] * 100) then
				npcHandler:say('Aqui tienes.', cid)
				doPlayerAddItem(cid, 2160, count[cid])
			else
				npcHandler:say('Lo siento, no tienes suficientes platinum coins.', cid)
			end
		else
			npcHandler:say('Bien, puedo ayudarte con algo mas?', cid)
		end
		Topic[cid] = 0
	elseif msgcontains(msg, 'change crystal') then
		npcHandler:say('Cuantas crystal coins deseas cambiar por platinum?', cid)
		Topic[cid] = 15
	elseif Topic[cid] == 15 then
		if getCount(msg) == -1 or getCount(msg) == 0 then
			npcHandler:say('Hmm, puedo ayudarte con algo mas?', cid)
			Topic[cid] = 0
		else
			count[cid] = getCount(msg)
			npcHandler:say('Entonces deseas que cambie ' .. count[cid] .. ' de tus crystal coins por ' .. count[cid] * 100 .. ' platinum coins?', cid)
			Topic[cid] = 16
		end
	elseif Topic[cid] == 16 then
		if msgcontains(msg, 'yes') then
			if doPlayerRemoveItem(cid, 2160, count[cid]) then
				npcHandler:say('Aqui tienes.', cid)
				doPlayerAddItem(cid, 2152, count[cid] * 100)
			else
				npcHandler:say('Lo siento, no tienes suficientes crystal coins.', cid)
			end
		else
			npcHandler:say('Bien, puedo ayudarte con algo mas?', cid)
		end
		Topic[cid] = 0
	elseif msgcontains(msg, 'change') then
		npcHandler:say('There are three different coin types in Tibia: 100 gold coins equal 1 platinum coin, 100 platinum coins equal 1 crystal coin. So if you\'d like to change 100 gold into 1 platinum, simply say \'{change gold}\' and then \'1 platinum\'.', cid)
		Topic[cid] = 0
	elseif msgcontains(msg, 'bank') then
		npcHandler:say('Podemos cambiar dinero por ti. Tambien puedes acceder a tu cuenta bancaria.', cid)
		Topic[cid] = 0
	end
	return TRUE
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
