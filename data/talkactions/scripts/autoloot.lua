-- Autoloot System
-- Storage para guardar la lista de items del autoloot
local AUTOLOOT_STORAGE = 45000
-- Storage para activar/desactivar el autoloot
local AUTOLOOT_ENABLED_STORAGE = 45001

function getPlayerAutoLootItems(cid)
	local storage = getPlayerStorageValue(cid, AUTOLOOT_STORAGE)
	if storage == -1 or storage == "" then
		return {}
	end
	
	local items = {}
	for itemName in storage:gmatch("[^,]+") do
		table.insert(items, itemName:lower():trim())
	end
	return items
end

function setPlayerAutoLootItems(cid, items)
	local storage = table.concat(items, ",")
	setPlayerStorageValue(cid, AUTOLOOT_STORAGE, storage)
end

function isItemInAutoLoot(cid, itemName)
	local items = getPlayerAutoLootItems(cid)
	itemName = itemName:lower():trim()
	for _, name in ipairs(items) do
		if name == itemName then
			return true
		end
	end
	return false
end

function isAutoLootEnabled(cid)
	local status = getPlayerStorageValue(cid, AUTOLOOT_ENABLED_STORAGE)
	return status == 1
end

function setAutoLootEnabled(cid, enabled)
	setPlayerStorageValue(cid, AUTOLOOT_ENABLED_STORAGE, enabled and 1 or 0)
end

function getPlayerMainContainer(cid)
	local BAG_ID = 1987
	local BACKPACK_ID = 1988
	
	local slotItem = getPlayerSlotItem(cid, CONST_SLOT_BACKPACK)
	if slotItem and slotItem.uid > 0 and isContainer(slotItem.uid) then
		if slotItem.itemid == BAG_ID or slotItem.itemid == BACKPACK_ID then
			return slotItem.uid
		end
	end
	
	for slot = 1, 10 do
		local item = getPlayerSlotItem(cid, slot)
		if item and item.uid > 0 and isContainer(item.uid) then
			if item.itemid == BAG_ID or item.itemid == BACKPACK_ID then
				return item.uid
			end
		end
	end
	
	local backpack = getPlayerSlotItem(cid, CONST_SLOT_BACKPACK)
	if backpack and backpack.uid > 0 and isContainer(backpack.uid) then
		return backpack.uid
	end
	
	for slot = 1, 10 do
		local item = getPlayerSlotItem(cid, slot)
		if item and item.uid > 0 and isContainer(item.uid) then
			return item.uid
		end
	end
	
	return nil
end

function addItemToPlayerBag(cid, itemid, count)
	local container = getPlayerMainContainer(cid)
	if not container then
		return false
	end
	
	-- Intentar stackear con items existentes primero
	local containerSize = getContainerSize(container)
	for i = 0, containerSize - 1 do
		local existingItem = getContainerItem(container, i)
		if existingItem and existingItem.itemid == itemid then
			local itemInfo = getItemInfo(itemid)
			if itemInfo and itemInfo.stackable then
				local added = doTransformItem(existingItem.uid, itemid, existingItem.type + count)
				if added then
					return true
				end
			end
		end
	end
	
	local ret = doAddContainerItem(container, itemid, count)
	if ret then
		return true
	end
	
	return false
end

function onSay(cid, words, param, channel)
	if words == "!auactivar" then
		if isAutoLootEnabled(cid) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "El autoloot ya esta activado.")
		else
			setAutoLootEnabled(cid, true)
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Autoloot activado. Los objetos se recogeran automaticamente al matar monstruos.")
		end
		return true
		
	elseif words == "!audesactivar" then
		if not isAutoLootEnabled(cid) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "El autoloot ya esta desactivado.")
		else
			setAutoLootEnabled(cid, false)
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Autoloot desactivado. Aun puedes usar !auloot manualmente.")
		end
		return true
		
	elseif words == "!auadd" then
		if param == "" then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Uso: !auadd <nombre del item>")
			return true
		end
		
		local itemName = param:lower():trim()
		local itemType = getItemIdByName(itemName)
		if not itemType or itemType == 0 then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "El item '" .. param .. "' no existe.")
			return true
		end
		
		if isItemInAutoLoot(cid, itemName) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "El item '" .. param .. "' ya esta en tu lista de autoloot.")
			return true
		end
		
		local items = getPlayerAutoLootItems(cid)
		table.insert(items, itemName)
		setPlayerAutoLootItems(cid, items)
		
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "El item '" .. param .. "' ha sido agregado a tu lista de autoloot.")
		return true
		
	elseif words == "!auremove" then
		if param == "" then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Uso: !auremove <nombre del item>")
			return true
		end
		
		local itemName = param:lower():trim()
		
		if not isItemInAutoLoot(cid, itemName) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "El item '" .. param .. "' no esta en tu lista de autoloot.")
			return true
		end
		
		local items = getPlayerAutoLootItems(cid)
		local newItems = {}
		for _, name in ipairs(items) do
			if name ~= itemName then
				table.insert(newItems, name)
			end
		end
		setPlayerAutoLootItems(cid, newItems)
		
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "El item '" .. param .. "' ha sido removido de tu lista de autoloot.")
		return true
		
	elseif words == "!aulist" then
		local items = getPlayerAutoLootItems(cid)
		local enabled = isAutoLootEnabled(cid)
		
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "=== ESTADO DEL AUTOLOOT ===")
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Estado: " .. (enabled and "ACTIVADO" or "DESACTIVADO"))
		
		if #items == 0 then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Tu lista de autoloot esta vacia.")
		else
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Items en autoloot (" .. #items .. "):")
			for i, name in ipairs(items) do
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, i .. ". " .. name)
			end
		end
		
		if not enabled then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Usa !auactivar para activar el autoloot.")
		end
		return true
		
	elseif words == "!auclear" then
		setPlayerStorageValue(cid, AUTOLOOT_STORAGE, "")
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Tu lista de autoloot ha sido limpiada.")
		return true
		
	elseif words == "!auconvert" then
		convertCoinsManually(cid)
		return true
		
	elseif words == "!auloot" then
		local playerPos = getCreaturePosition(cid)
		
		local corpse = nil
		for stackpos = 0, 255 do
			playerPos.stackpos = stackpos
			local thing = getThingFromPos(playerPos)
			if thing and thing.uid > 0 and thing.itemid > 0 then
				if isCorpse(thing.uid) and isContainer(thing.uid) then
					corpse = thing
					break
				end
			end
		end
		
		if not corpse then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "Debes estar sobre un cadaver para usar este comando.")
			return true
		end
		
		local autoLootItems = getPlayerAutoLootItems(cid)
		if #autoLootItems == 0 then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Tu lista de autoloot esta vacia. Usa !auadd para agregar items.")
			return true
		end
		
		if not getPlayerMainContainer(cid) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "Necesitas una mochila o bolsa para recoger items.")
			return true
		end
		
		local lootedItems = {}
		local itemsToRemove = {}
		
		for i = getContainerSize(corpse.uid) - 1, 0, -1 do
			local item = getContainerItem(corpse.uid, i)
			if item and item.itemid > 0 then
				local itemName = getItemNameById(item.itemid):lower()
				
				for _, autoLootName in ipairs(autoLootItems) do
					if itemName:find(autoLootName) or autoLootName:find(itemName) or itemName == autoLootName then
						if addItemToPlayerBag(cid, item.itemid, item.type > 0 and item.type or 1) then
							table.insert(itemsToRemove, item.uid)
							
							if not lootedItems[itemName] then
								lootedItems[itemName] = 0
							end
							lootedItems[itemName] = lootedItems[itemName] + (item.type > 0 and item.type or 1)
						end
						break
					end
				end
			end
		end
		
		for _, uid in ipairs(itemsToRemove) do
			doRemoveItem(uid)
		end
		
		if next(lootedItems) then
			local message = "Autoloot: "
			local count = 0
			for itemName, quantity in pairs(lootedItems) do
				if count > 0 then
					message = message .. ", "
				end
				if quantity > 1 then
					message = message .. quantity .. "x " .. itemName
				else
					message = message .. itemName
				end
				count = count + 1
			end
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, message)
		else
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "No se encontraron items de autoloot en este cadaver.")
		end
		
		return true
	end
	
	return true
end

function string:trim()
	return self:match("^%s*(.-)%s*$")
end

-- Comando para convertir monedas manualmente
function convertCoinsManually(cid)
	local container = getPlayerMainContainer(cid)
	if not container then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "Necesitas una mochila o bolsa.")
		return false
	end
	
	local GOLD_COIN = 2148
	local PLATINUM_COIN = 2152
	local CRYSTAL_COIN = 2160
	
	local goldCount = 0
	local platinumCount = 0
	local itemsToRemove = {}
	
	-- Contar monedas
	local containerSize = getContainerSize(container)
	for i = 0, containerSize - 1 do
		local item = getContainerItem(container, i)
		if item then
			if item.itemid == GOLD_COIN then
				goldCount = goldCount + (item.type or 1)
				table.insert(itemsToRemove, item.uid)
			elseif item.itemid == PLATINUM_COIN then
				platinumCount = platinumCount + (item.type or 1)
				table.insert(itemsToRemove, item.uid)
			end
		end
	end
	
	if goldCount < 100 and platinumCount < 100 then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Necesitas al menos 100 gold coins o 100 platinum coins para convertir.")
		return false
	end
	
	-- Remover todas las monedas
	for _, uid in ipairs(itemsToRemove) do
		doRemoveItem(uid)
	end
	
	-- Convertir
	local platinumFromGold = math.floor(goldCount / 100)
	local remainingGold = goldCount % 100
	platinumCount = platinumCount + platinumFromGold
	
	local crystalFromPlatinum = math.floor(platinumCount / 100)
	local remainingPlatinum = platinumCount % 100
	
	-- Agregar monedas convertidas
	if crystalFromPlatinum > 0 then
		while crystalFromPlatinum > 0 do
			local toAdd = math.min(crystalFromPlatinum, 100)
			doAddContainerItem(container, CRYSTAL_COIN, toAdd)
			crystalFromPlatinum = crystalFromPlatinum - toAdd
		end
	end
	
	if remainingPlatinum > 0 then
		while remainingPlatinum > 0 do
			local toAdd = math.min(remainingPlatinum, 100)
			doAddContainerItem(container, PLATINUM_COIN, toAdd)
			remainingPlatinum = remainingPlatinum - toAdd
		end
	end
	
	if remainingGold > 0 then
		while remainingGold > 0 do
			local toAdd = math.min(remainingGold, 100)
			doAddContainerItem(container, GOLD_COIN, toAdd)
			remainingGold = remainingGold - toAdd
		end
	end
	
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Monedas convertidas exitosamente!")
	return true
end
