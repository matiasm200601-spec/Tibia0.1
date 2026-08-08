-- Autoloot System - Creature Scripts
-- Sistema mejorado: funciona desde cualquier distancia + auto stack + conversión de monedas
local AUTOLOOT_STORAGE = 45000
local AUTOLOOT_ENABLED_STORAGE = 45001

-- IDs de monedas
local GOLD_COIN = 2148
local PLATINUM_COIN = 2152
local CRYSTAL_COIN = 2160

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

function isAutoLootEnabled(cid)
	local status = getPlayerStorageValue(cid, AUTOLOOT_ENABLED_STORAGE)
	return status == 1
end

function getPlayerMainContainer(cid)
	local backpack = getPlayerSlotItem(cid, CONST_SLOT_BACKPACK)
	if backpack and backpack.uid > 0 and isContainer(backpack.uid) then
		return backpack.uid
	end
	
	-- Buscar en otros slots si no tiene backpack
	for slot = 1, 10 do
		local item = getPlayerSlotItem(cid, slot)
		if item and item.uid > 0 and isContainer(item.uid) then
			return item.uid
		end
	end
	
	return nil
end

function stackItemInContainer(container, itemid, count)
	-- Buscar items existentes del mismo tipo para stackear
	local containerSize = getContainerSize(container)
	for i = 0, containerSize - 1 do
		local existingItem = getContainerItem(container, i)
		if existingItem and existingItem.itemid == itemid then
			local currentCount = existingItem.type or 1
			local maxStack = 100
			
			if currentCount < maxStack then
				local spaceLeft = maxStack - currentCount
				local toAdd = math.min(spaceLeft, count)
				doTransformItem(existingItem.uid, itemid, currentCount + toAdd)
				count = count - toAdd
				
				if count <= 0 then
					return 0 -- Todo fue stackeado
				end
			end
		end
	end
	
	return count -- Retorna lo que quedó sin stackear
end

function addItemToPlayerBag(cid, itemid, count)
	local container = getPlayerMainContainer(cid)
	if not container then
		return false
	end
	
	local itemInfo = getItemInfo(itemid)
	if not itemInfo then
		return false
	end
	
	-- Si es stackeable, intentar stackear primero
	if itemInfo.stackable then
		count = stackItemInContainer(container, itemid, count)
		
		-- Si todo fue stackeado, retornar true
		if count <= 0 then
			return true
		end
		
		-- Si quedó algo, agregar nuevos stacks
		while count > 0 do
			local toAdd = math.min(count, 100)
			local ret = doAddContainerItem(container, itemid, toAdd)
			if not ret then
				return false
			end
			count = count - toAdd
		end
		return true
	else
		-- Item no stackeable, agregar directamente
		local ret = doAddContainerItem(container, itemid, count)
		return ret ~= nil and ret ~= false
	end
end

function convertCoins(cid)
	local container = getPlayerMainContainer(cid)
	if not container then
		return
	end
	
	local goldCount = 0
	local platinumCount = 0
	local itemsToRemove = {}
	
	-- Contar monedas y marcar para remover
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
	
	-- Remover todas las monedas
	for _, uid in ipairs(itemsToRemove) do
		doRemoveItem(uid)
	end
	
	-- Convertir gold a platinum
	local platinumFromGold = math.floor(goldCount / 100)
	local remainingGold = goldCount % 100
	platinumCount = platinumCount + platinumFromGold
	
	-- Convertir platinum a crystal
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
end

function findCorpseAtPosition(pos)
	for stackpos = 0, 255 do
		pos.stackpos = stackpos
		local thing = getThingFromPos(pos)
		if thing and thing.uid > 0 and thing.itemid > 0 then
			if isContainer(thing.uid) and isCorpse(thing.uid) then
				return thing
			end
		end
	end
	return nil
end

function onKill(cid, target, lastHit)
	if not isPlayer(cid) or not isMonster(target) then
		return true
	end
	
	if not isAutoLootEnabled(cid) then
		return true
	end
	
	local autoLootItems = getPlayerAutoLootItems(cid)
	if #autoLootItems == 0 then
		return true
	end
	
	if not getPlayerMainContainer(cid) then
		return true
	end
	
	-- Guardar la posición del monstruo ANTES de que muera
	local monsterPos = getCreaturePosition(target)
	
	addEvent(function()
		if not isPlayer(cid) then
			return
		end
		
		-- Buscar el corpse en la posición donde murió el monstruo
		local corpse = findCorpseAtPosition(monsterPos)
		
		if not corpse then
			return
		end
		
		local lootedItems = {}
		local itemsToRemove = {}
		local hasCoins = false
		
		-- Recorrer items del corpse
		local containerSize = getContainerSize(corpse.uid)
		for i = containerSize - 1, 0, -1 do
			local item = getContainerItem(corpse.uid, i)
			if item and item.itemid > 0 then
				local itemName = getItemNameById(item.itemid):lower()
				
				-- Verificar si el item está en la lista de autoloot
				for _, autoLootName in ipairs(autoLootItems) do
					if itemName:find(autoLootName) or autoLootName:find(itemName) or itemName == autoLootName then
						local count = item.type > 0 and item.type or 1
						
						if addItemToPlayerBag(cid, item.itemid, count) then
							table.insert(itemsToRemove, item.uid)
							
							if not lootedItems[itemName] then
								lootedItems[itemName] = 0
							end
							lootedItems[itemName] = lootedItems[itemName] + count
							
							-- Marcar si se looteó alguna moneda
							if item.itemid == GOLD_COIN or item.itemid == PLATINUM_COIN or item.itemid == CRYSTAL_COIN then
								hasCoins = true
							end
						end
						break
					end
				end
			end
		end
		
		-- Remover items del corpse
		for _, uid in ipairs(itemsToRemove) do
			doRemoveItem(uid)
		end
		
		-- Convertir monedas si se looteó alguna
		if hasCoins then
			convertCoins(cid)
		end
		
		-- Mostrar mensaje de items looteados
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
		end
	end, 500)
	
	return true
end

function string:trim()
	return self:match("^%s*(.-)%s*$")
end

function onLogin(cid)
	return true
end
