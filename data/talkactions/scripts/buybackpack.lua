-- Buy Backpack Command
-- !backpack - Comprar una backpack por 100 platinum coins o 1 crystal coin

function onSay(cid, words, param, channel)
	local BACKPACK_ID = 1988
	local PLATINUM_ID = 2152
	local CRYSTAL_ID = 2160
	local PLATINUM_COST = 100
	local CRYSTAL_COST = 1
	
	-- Verificar si tiene 1 crystal coin
	if doPlayerRemoveItem(cid, CRYSTAL_ID, CRYSTAL_COST) then
		-- Intentar agregar a la backpack o bag del jugador
		local container = getPlayerSlotItem(cid, CONST_SLOT_BACKPACK)
		
		if container and container.uid > 0 and isContainer(container.uid) then
			-- Buscar bag (1987) o backpack (1988) en el slot de backpack
			if container.itemid == 1987 or container.itemid == 1988 then
				doAddContainerItem(container.uid, BACKPACK_ID, 1)
				doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You have purchased a backpack for 1 crystal coin.")
				return true
			end
		end
		
		-- Si no tiene container, buscar en otros slots
		for slot = 1, 10 do
			local item = getPlayerSlotItem(cid, slot)
			if item and item.uid > 0 and isContainer(item.uid) then
				if item.itemid == 1987 or item.itemid == 1988 then
					doAddContainerItem(item.uid, BACKPACK_ID, 1)
					doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You have purchased a backpack for 1 crystal coin.")
					return true
				end
			end
		end
		
		-- Si no hay espacio en containers, poner en el suelo
		local pos = getCreaturePosition(cid)
		doCreateItem(BACKPACK_ID, 1, pos)
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You have purchased a backpack for 1 crystal coin. It has been placed on the ground.")
		return true
	end
	
	-- Si no tiene crystal coin, intentar con platinum coins
	if doPlayerRemoveItem(cid, PLATINUM_ID, PLATINUM_COST) then
		-- Intentar agregar a la backpack o bag del jugador
		local container = getPlayerSlotItem(cid, CONST_SLOT_BACKPACK)
		
		if container and container.uid > 0 and isContainer(container.uid) then
			-- Buscar bag (1987) o backpack (1988) en el slot de backpack
			if container.itemid == 1987 or container.itemid == 1988 then
				doAddContainerItem(container.uid, BACKPACK_ID, 1)
				doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You have purchased a backpack for 100 platinum coins.")
				return true
			end
		end
		
		-- Si no tiene container, buscar en otros slots
		for slot = 1, 10 do
			local item = getPlayerSlotItem(cid, slot)
			if item and item.uid > 0 and isContainer(item.uid) then
				if item.itemid == 1987 or item.itemid == 1988 then
					doAddContainerItem(item.uid, BACKPACK_ID, 1)
					doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You have purchased a backpack for 100 platinum coins.")
					return true
				end
			end
		end
		
		-- Si no hay espacio en containers, poner en el suelo
		local pos = getCreaturePosition(cid)
		doCreateItem(BACKPACK_ID, 1, pos)
		doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You have purchased a backpack for 100 platinum coins. It has been placed on the ground.")
		return true
	end
	
	-- Si no tiene suficiente dinero
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "You need 100 platinum coins or 1 crystal coin to buy a backpack.")
	return true
end
