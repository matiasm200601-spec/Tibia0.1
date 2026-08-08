-- Loot Boost System
-- Aumenta la probabilidad de que los monstruos suelten todos sus items

local LOOT_BOOST_MULTIPLIER = 1.5  -- Multiplica las chances por 1.5 (50% más probabilidad)

function onDeath(cid, corpse, killer)
	if not isMonster(cid) then
		return true
	end
	
	-- Este script se ejecuta después de que el loot ya fue generado
	-- El rateLoot en config.lua ya se encarga de aumentar las probabilidades base
	
	return true
end
