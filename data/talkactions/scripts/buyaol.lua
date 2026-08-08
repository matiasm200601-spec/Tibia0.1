-- Buy AOL Command
-- !aol - Comprar un Amulet of Loss por 3 crystal coins

function onSay(cid, words, param, channel)
	local AOL_ID = 2173
	local CRYSTAL_ID = 2160
	local CRYSTAL_COST = 3
	
	-- Verificar si tiene 3 crystal coins
	if doPlayerRemoveItem(cid, CRYSTAL_ID, CRYSTAL_COST) then
		-- Agregar el AOL al jugador
		doPlayerAddItem(cid, AOL_ID, 1)
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You have purchased an Amulet of Loss for 3 crystal coins.")
		return true
	end
	
	-- Si no tiene suficiente dinero
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "You need 3 crystal coins to buy an Amulet of Loss.")
	return true
end
