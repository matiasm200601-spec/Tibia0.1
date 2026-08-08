-- Death System - Solo pérdida de experiencia
-- Pérdida escalonada según el nivel: más nivel = más experiencia perdida
-- Items protegidos hasta nivel 39, desde nivel 40 pueden perderse

local EXPERIENCE_LOSS = {
	-- [nivel] = porcentaje de experiencia perdida
	[1] = 0,      -- Nivel 1-9: 0% pérdida
	[10] = 2,     -- Nivel 10-19: 2% pérdida
	[20] = 3,     -- Nivel 20-29: 3% pérdida
	[30] = 4,     -- Nivel 30-39: 4% pérdida
	[40] = 5,     -- Nivel 40-49: 5% pérdida
	[50] = 6,     -- Nivel 50-59: 6% pérdida
	[60] = 7,     -- Nivel 60-69: 7% pérdida
	[70] = 8,     -- Nivel 70-79: 8% pérdida
	[80] = 9,     -- Nivel 80-89: 9% pérdida
	[90] = 10,    -- Nivel 90-99: 10% pérdida
	[100] = 10,   -- Nivel 100+: 10% pérdida
}

function getExperienceLossPercent(level)
	-- Encontrar el rango de nivel apropiado
	for levelThreshold = 100, 1, -10 do
		if level >= levelThreshold then
			return EXPERIENCE_LOSS[levelThreshold] or 0
		end
	end
	return 0
end

function onPrepareDeath(cid, deathList)
	local level = getPlayerLevel(cid)
	
	-- Prevenir pérdida de mana y skills siempre
	doPlayerSetLossPercent(cid, PLAYERLOSS_MANA, 0)
	doPlayerSetLossPercent(cid, PLAYERLOSS_SKILLS, 0)
	
	-- Items y containers: protegidos hasta nivel 39
	if level < 40 then
		doPlayerSetLossPercent(cid, PLAYERLOSS_ITEMS, 0)
		doPlayerSetLossPercent(cid, PLAYERLOSS_CONTAINERS, 0)
	else
		-- Desde nivel 40: 10% de pérdida de items
		doPlayerSetLossPercent(cid, PLAYERLOSS_ITEMS, 100)
		doPlayerSetLossPercent(cid, PLAYERLOSS_CONTAINERS, 100)
	end
	
	-- Configurar pérdida de experiencia según nivel
	local lossPercent = getExperienceLossPercent(level)
	
	-- La pérdida de experiencia se calcula como porcentaje
	-- Multiplicamos por 10 porque el sistema usa valores de 0-1000 (10 = 1%)
	doPlayerSetLossPercent(cid, PLAYERLOSS_EXPERIENCE, lossPercent * 10)
	
	return true
end

function onDeath(cid, corpse, deathList)
	local level = getPlayerLevel(cid)
	local currentExp = getPlayerExperience(cid)
	local lossPercent = getExperienceLossPercent(level)
	
	-- Calcular experiencia perdida
	local expLost = math.floor(currentExp * (lossPercent / 100))
	
	-- Guardar el nivel actual para prevenir bajada de nivel
	local currentLevel = level
	local currentMaxHealth = getCreatureMaxHealth(cid)
	local currentMaxMana = getCreatureMaxMana(cid)
	
	-- Después de un pequeño delay, verificar y restaurar nivel si bajó
	addEvent(function()
		if not isPlayer(cid) then
			return
		end
		
		local newLevel = getPlayerLevel(cid)
		
		-- Si el jugador bajó de nivel, restaurarlo
		if newLevel < currentLevel then
			local levelDiff = currentLevel - newLevel
			
			-- Restaurar nivel
			for i = 1, levelDiff do
				doPlayerAddLevel(cid, 1, false)
			end
			
			-- Restaurar HP y Mana máximos
			setCreatureMaxHealth(cid, currentMaxHealth)
			setCreatureMaxMana(cid, currentMaxMana)
			
			-- Curar completamente
			doCreatureAddHealth(cid, getCreatureMaxHealth(cid))
			doCreatureAddMana(cid, getCreatureMaxMana(cid))
			
			-- Mensaje al jugador
			if level < 40 then
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Has muerto y perdido " .. expLost .. " puntos de experiencia (" .. lossPercent .. "%).")
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Tu nivel, HP, Mana e items han sido restaurados.")
			else
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Has muerto y perdido " .. expLost .. " puntos de experiencia (" .. lossPercent .. "%).")
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Tu nivel, HP y Mana han sido restaurados. Algunos items pudieron haberse perdido.")
			end
		else
			-- Solo perdió experiencia, no bajó de nivel
			if level < 40 then
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Has muerto y perdido " .. expLost .. " puntos de experiencia (" .. lossPercent .. "%).")
			else
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Has muerto y perdido " .. expLost .. " puntos de experiencia (" .. lossPercent .. "%). Algunos items pudieron haberse perdido.")
			end
		end
	end, 1000)
	
	return true
end
