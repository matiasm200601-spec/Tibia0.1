-- Protection Death System
-- Triple protección para que jugadores menores de nivel 40 no pierdan items

function onPrepareDeath(cid, deathList)
	local level = getPlayerLevel(cid)
	
	if level < 40 then
		-- Forzar pérdida a 0 antes de morir
		doPlayerSetLossPercent(cid, PLAYERLOSS_EXPERIENCE, 0)
		doPlayerSetLossPercent(cid, PLAYERLOSS_MANA, 0)
		doPlayerSetLossPercent(cid, PLAYERLOSS_SKILLS, 0)
		doPlayerSetLossPercent(cid, PLAYERLOSS_ITEMS, 0)
		doPlayerSetLossPercent(cid, PLAYERLOSS_CONTAINERS, 0)
	end
	
	return true
end

function onDeath(cid, corpse, deathList)
	local level = getPlayerLevel(cid)
	
	if level < 40 then
		-- Forzar pérdida a 0 al morir
		doPlayerSetLossPercent(cid, PLAYERLOSS_EXPERIENCE, 0)
		doPlayerSetLossPercent(cid, PLAYERLOSS_MANA, 0)
		doPlayerSetLossPercent(cid, PLAYERLOSS_SKILLS, 0)
		doPlayerSetLossPercent(cid, PLAYERLOSS_ITEMS, 0)
		doPlayerSetLossPercent(cid, PLAYERLOSS_CONTAINERS, 0)
	end
	
	return true
end
