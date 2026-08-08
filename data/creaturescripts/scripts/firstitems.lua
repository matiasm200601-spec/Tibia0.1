-- First Items System
-- Jugadores empiezan con una backpack (1988) con equipo según su vocación

local FIRST_ITEMS_STORAGE = 30001

local ITEMS_BY_VOCATION = {
	-- Sorcerer
	[1] = {
		{id = 2190, count = 1},  -- wand of vortex
		{id = 2643, count = 1},  -- leather boots
		{id = 2465, count = 1},  -- brass armor
		{id = 2478, count = 1},  -- brass legs
		{id = 2460, count = 1},  -- brass helmet
		{id = 2789, count = 20}, -- brown mushroom
		{id = 2511, count = 1},  -- brass shield
		{id = 2160, count = 2}   -- crystal coin
	},
	-- Druid
	[2] = {
		{id = 2182, count = 1},  -- snakebite rod
		{id = 2643, count = 1},  -- leather boots
		{id = 2465, count = 1},  -- brass armor
		{id = 2478, count = 1},  -- brass legs
		{id = 2460, count = 1},  -- brass helmet
		{id = 2789, count = 20}, -- brown mushroom
		{id = 2511, count = 1},  -- brass shield
		{id = 2160, count = 2}   -- crystal coin
	},
	-- Paladin
	[3] = {
		{id = 2456, count = 1},   -- bow (arco)
		{id = 2544, count = 200}, -- arrows (flechas) - reducido a 200
		{id = 2643, count = 1},   -- leather boots
		{id = 2465, count = 1},   -- brass armor
		{id = 2478, count = 1},   -- brass legs
		{id = 2460, count = 1},   -- brass helmet
		{id = 2789, count = 20},  -- brown mushroom
		{id = 2511, count = 1},   -- brass shield
		{id = 2160, count = 2}    -- crystal coin
	},
	-- Knight
	[4] = {
		{id = 2428, count = 1},  -- orcish axe
		{id = 2376, count = 1},  -- sword
		{id = 2643, count = 1},  -- leather boots
		{id = 2465, count = 1},  -- brass armor
		{id = 2478, count = 1},  -- brass legs
		{id = 2460, count = 1},  -- brass helmet
		{id = 2789, count = 20}, -- brown mushroom
		{id = 2511, count = 1},  -- brass shield
		{id = 2160, count = 2}   -- crystal coin
	}
}

function onLogin(cid)
	if getPlayerStorageValue(cid, FIRST_ITEMS_STORAGE) == 1 then
		return true
	end
	
	local vocation = getPlayerVocation(cid)
	
	-- Si no tiene vocación aún (novice), esperar
	if vocation == 0 then
		return true
	end
	
	local items = ITEMS_BY_VOCATION[vocation]
	if not items then
		return true
	end
	
	-- Crear backpack (ID 1988)
	local backpack = doPlayerAddItem(cid, 1988, 1)
	
	if backpack then
		-- Agregar todos los items dentro de la backpack
		for _, item in ipairs(items) do
			doAddContainerItem(backpack, item.id, item.count)
		end
		
		doPlayerSendTextMessage(cid, MESSAGE_EVENT_DEFAULT, "Welcome! You have received your starting equipment.")
		setPlayerStorageValue(cid, FIRST_ITEMS_STORAGE, 1)
	end
	
	return true
end
