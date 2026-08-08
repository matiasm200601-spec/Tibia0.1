-- Auto Stack System
-- Junta objetos automáticamente en el inventario del jugador

local AUTOSTACK_STORAGE = 45100
local AUTOSTACK_ENABLED_STORAGE = 45101

function stackItemsInContainer(cid, container)
	if not container or not isContainer(container) then
		return 0
	end
	
	local stacked = 0
	local size = getContainerSize(container)
	local items = {}
	
	-- Primero, recolectar todos los items
	for i = 0, size - 1 do
		local item = getContainerItem(container, i)
		if item and item.itemid > 0 then
			local itemInfo = getItemInfo(item.itemid)
			if itemInfo and itemInfo.stackable then
				if not items[item.itemid] then
					items[item.itemid] = {}
				end
				table.insert(items[item.itemid], {uid = item.uid, count = item.type or 1, slot = i})
			elseif isContainer(item.uid) then
				-- Recursivamente juntar items en containers dentro de containers
				stacked = stacked + stackItemsInContainer(cid, item.uid)
			end
		end
	end
	
	-- Ahora juntar items del mismo tipo
	for itemid, itemList in pairs(items) do
		if #itemList > 1 then
			-- Ordenar por cantidad (los más llenos primero)
			table.sort(itemList, function(a, b) return a.count > b.count end)
			
			local baseItem = itemList[1]
			local maxStack = 100
			
			for i = 2, #itemList do
				local currentItem = itemList[i]
				
				if baseItem.count < maxStack then
					local spaceLeft = maxStack - baseItem.count
					local amountToAdd = math.min(spaceLeft, currentItem.count)
					
					-- Agregar a la pila base
					doTransformItem(baseItem.uid, itemid, baseItem.count + amountToAdd)
					baseItem.count = baseItem.count + amountToAdd
					
					-- Reducir o eliminar el item actual
					if currentItem.count > amountToAdd then
						doTransformItem(currentItem.uid, itemid, currentItem.count - amountToAdd)
						currentItem.count = currentItem.count - amountToAdd
					else
						doRemoveItem(currentItem.uid)
						stacked = stacked + 1
					end
				end
				
				-- Si la pila base está llena, buscar la siguiente
				if baseItem.count >= maxStack then
					for j = i, #itemList do
						if itemList[j].count < maxStack then
							baseItem = itemList[j]
							break
						end
					end
				end
			end
		end
	end
	
	return stacked
end

function onSay(cid, words, param, channel)
	if words == "!autojuntar" or words == "!autostack" then
		local backpack = getPlayerSlotItem(cid, CONST_SLOT_BACKPACK)
		if not backpack or backpack.uid == 0 or not isContainer(backpack.uid) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "No tienes una backpack equipada.")
			return true
		end
		
		local stacked = stackItemsInContainer(cid, backpack.uid)
		
		if stacked > 0 then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Items juntados: " .. stacked .. " pilas combinadas.")
		else
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "No hay items para juntar.")
		end
		
		return true
	end
	
	return false
end
