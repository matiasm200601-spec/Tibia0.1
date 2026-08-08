-- Protection Level System - Login Handler
-- Jugadores menores de nivel 40 no pierden items ni experiencia

function onLogin(cid)
	local level = getPlayerLevel(cid)
	
	if level < 40 then
		-- Sin pérdida de items, exp, skills antes del nivel 40
		doPlayerSetLossPercent(cid, PLAYERLOSS_EXPERIENCE, 0)
		doPlayerSetLossPercent(cid, PLAYERLOSS_MANA, 0)
		doPlayerSetLossPercent(cid, PLAYERLOSS_SKILLS, 0)
		doPlayerSetLossPercent(cid, PLAYERLOSS_ITEMS, 0)
		doPlayerSetLossPercent(cid, PLAYERLOSS_CONTAINERS, 0)
	else
		-- A partir del nivel 40, pérdida normal
		doPlayerSetLossPercent(cid, PLAYERLOSS_EXPERIENCE, 10)
		doPlayerSetLossPercent(cid, PLAYERLOSS_MANA, 10)
		doPlayerSetLossPercent(cid, PLAYERLOSS_SKILLS, 10)
		doPlayerSetLossPercent(cid, PLAYERLOSS_ITEMS, 10)
		doPlayerSetLossPercent(cid, PLAYERLOSS_CONTAINERS, 10)
	end
	
	return true
end
