-- Advanced Save System with Level Rewards, HP/Mana Bonuses, Spell Notifications, and Full Regeneration

local LEVEL_REWARDS = {
	[10] = {item = 2160, count = 2},  -- 2 crystal coins
	[20] = {item = 2160, count = 4},  -- 4 crystal coins
	[30] = {item = 2160, count = 5},  -- 5 crystal coins
	[100] = {item = 2160, count = 10} -- 10 crystal coins
}

local LEVEL_REWARD_STORAGE_BASE = 45100

function onAdvance(cid, skill, oldLevel, newLevel)
	-- Solo procesar cuando sube de nivel (no skills)
	if skill ~= SKILL__LEVEL then
		return true
	end
	
	-- Guardar el jugador
	doPlayerSave(cid)
	
	-- Regenerar completamente HP y Mana
	doCreatureAddHealth(cid, getCreatureMaxHealth(cid))
	doCreatureAddMana(cid, getCreatureMaxMana(cid))
	
	-- HP/Mana Bonuses por vocación
	local vocation = getPlayerVocation(cid)
	
	-- Sorcerer (ID 1) = +2 mana (con mensaje)
	if vocation == 1 then
		setPlayerStorageValue(cid, 45050, getPlayerStorageValue(cid, 45050) + 2)
		local currentMaxMana = getCreatureMaxMana(cid)
		setCreatureMaxMana(cid, currentMaxMana + 2)
		doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, "You gained 2 maximum mana points!")
	
	-- Druid (ID 2) = +2 mana (SIN mensaje)
	elseif vocation == 2 then
		setPlayerStorageValue(cid, 45050, getPlayerStorageValue(cid, 45050) + 2)
		local currentMaxMana = getCreatureMaxMana(cid)
		setCreatureMaxMana(cid, currentMaxMana + 2)
		-- NO se envía mensaje al druid
	
	-- Knight (ID 4) = +2 hp
	elseif vocation == 4 then
		setPlayerStorageValue(cid, 45051, getPlayerStorageValue(cid, 45051) + 2)
		local currentMaxHealth = getCreatureMaxHealth(cid)
		setCreatureMaxHealth(cid, currentMaxHealth + 2)
		doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, "You gained 2 maximum health points!")
	
	-- Paladin (ID 3) = +1 hp, +1 mana
	elseif vocation == 3 then
		setPlayerStorageValue(cid, 45051, getPlayerStorageValue(cid, 45051) + 1)
		setPlayerStorageValue(cid, 45050, getPlayerStorageValue(cid, 45050) + 1)
		local currentMaxHealth = getCreatureMaxHealth(cid)
		local currentMaxMana = getCreatureMaxMana(cid)
		setCreatureMaxHealth(cid, currentMaxHealth + 1)
		setCreatureMaxMana(cid, currentMaxMana + 1)
		doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, "You gained 1 maximum health point and 1 maximum mana point!")
	end
	
	-- Level Rewards
	if LEVEL_REWARDS[newLevel] then
		local reward = LEVEL_REWARDS[newLevel]
		local storageKey = LEVEL_REWARD_STORAGE_BASE + newLevel
		
		if getPlayerStorageValue(cid, storageKey) ~= 1 then
			doPlayerAddItem(cid, reward.item, reward.count)
			setPlayerStorageValue(cid, storageKey, 1)
			
			local itemName = getItemNameById(reward.item)
			doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, "You have received " .. reward.count .. " " .. itemName .. " as a level " .. newLevel .. " reward!")
		end
	end
	
	-- Spell Notifications (mostrar palabras mágicas, no nombre)
	local spells = getPlayerLearnedInstantSpells(cid)
	if spells and #spells > 0 then
		for _, spell in ipairs(spells) do
			-- Verificar si el spell se desbloqueó exactamente en este nivel
			if spell.level == newLevel and spell.mlevel <= getPlayerMagLevel(cid) then
				-- Mostrar las palabras mágicas (spell.words) no el nombre
				if spell.words and spell.words ~= "" then
					doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, "You have unlocked a new spell: " .. spell.words)
				end
			end
		end
	end
	
	-- Protección de nivel 40
	if newLevel == 40 then
		doPlayerSetLossPercent(cid, PLAYERLOSS_EXPERIENCE, 10)
		doPlayerSetLossPercent(cid, PLAYERLOSS_MANA, 10)
		doPlayerSetLossPercent(cid, PLAYERLOSS_SKILLS, 10)
		doPlayerSetLossPercent(cid, PLAYERLOSS_ITEMS, 10)
		doPlayerSetLossPercent(cid, PLAYERLOSS_CONTAINERS, 10)
		
		doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, "You have reached level 40! You can now lose items and experience when you die, and engage in PvP combat.")
	end
	
	return true
end
