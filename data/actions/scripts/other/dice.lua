-- Sistema de Dados
-- Dados normales: tiran 1-6 normal
-- Dados del casino (coordenadas específicas): sistema de apuestas

local LOCKER_IDS = {2589, 2590, 2591, 2592}
local CRYSTAL_COIN_ID = 2160
local MIN_BET = 2
local HOUSE_EDGE = 0.10 -- 10%

-- Coordenadas de los dados del casino
local CASINO_DICE = {
    {x = 32354, y = 32225, z = 7},
    {x = 32354, y = 32231, z = 7}
}

function isCasinoDice(pos)
    for _, casinoPos in ipairs(CASINO_DICE) do
        if pos.x == casinoPos.x and pos.y == casinoPos.y and pos.z == casinoPos.z then
            return true
        end
    end
    return false
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
    -- Si el dado NO está en las coordenadas del casino, funciona normal
    if not isCasinoDice(fromPosition) then
        -- Dado normal (1-6)
        if(fromPosition.x ~= CONTAINER_POSITION) then
            doSendMagicEffect(fromPosition, CONST_ME_CRAPS)
        end
        
        local value = math.random(5792, 5797)
        doTransformItem(item.uid, value)
        doCreatureSay(cid, getCreatureName(cid) .. ' rolled a ' .. value - 5791 .. '.', TALKTYPE_ORANGE_1)
        return true
    end
    
    -- DADO DEL CASINO: Buscar apuestas
    local totalBet = 0
    local coinsToRemove = {}
    
    for dx = -2, 2 do
        for dy = -2, 2 do
            local searchPos = {
                x = fromPosition.x + dx,
                y = fromPosition.y + dy,
                z = fromPosition.z
            }
            
            for stackpos = 0, 255 do
                searchPos.stackpos = stackpos
                local thing = getThingFromPos(searchPos)
                
                if thing and thing.itemid then
                    local isValidLocker = false
                    for _, lockerId in ipairs(LOCKER_IDS) do
                        if thing.itemid == lockerId then
                            isValidLocker = true
                            break
                        end
                    end
                    
                    if isValidLocker then
                        for topStackpos = stackpos + 1, 255 do
                            searchPos.stackpos = topStackpos
                            local topItem = getThingFromPos(searchPos)
                            
                            if topItem and topItem.uid > 0 and topItem.itemid == CRYSTAL_COIN_ID then
                                local count = topItem.type > 0 and topItem.type or 1
                                totalBet = totalBet + count
                                table.insert(coinsToRemove, {uid = topItem.uid, count = count})
                            elseif not topItem or topItem.itemid == 0 then
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Si no hay apuesta, solo mostrar efecto
    if totalBet < MIN_BET then
        doSendMagicEffect(fromPosition, CONST_ME_CRAPS)
        return true
    end
    
    -- Hay apuesta detectada, solo mostrar efecto
    doSendMagicEffect(fromPosition, CONST_ME_CRAPS)
    
    return true
end