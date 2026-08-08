-- Sistema de Apuestas con Dado
-- Dado ID: 5792
-- Locker IDs: 2589, 2590, 2591, 2592
-- Crystal Coin ID: 2160
-- Minimo: 2 crystal coins
-- Comision de la casa: 10%

local DICE_ID = 5792
local LOCKER_IDS = {2589, 2590, 2591, 2592}
local CRYSTAL_COIN_ID = 2160
local MIN_BET = 2
local HOUSE_EDGE = 0.10 -- 10%

-- Coordenada especial del jugador que fuerza un dado específico
local SPECIAL_PLAYER_POS = {x = 32352, y = 32226, z = 7}
local SPECIAL_DICE_POS = {x = 32354, y = 32225, z = 7}

function onSay(cid, words, param, channel)
    local bet = words:upper()
    
    -- Validar que sea "H" o "L"
    if bet ~= "H" and bet ~= "L" then
        return false
    end
    
    local playerPos = getCreaturePosition(cid)
    local dicePos = nil
    local diceItem = nil
    
    -- Verificar si el jugador está en la posición especial
    local isSpecialPosition = (playerPos.x == SPECIAL_PLAYER_POS.x and 
                               playerPos.y == SPECIAL_PLAYER_POS.y and 
                               playerPos.z == SPECIAL_PLAYER_POS.z)
    
    if isSpecialPosition then
        -- Buscar el dado en la posición específica
        for stackpos = 0, 255 do
            local checkPos = {x = SPECIAL_DICE_POS.x, y = SPECIAL_DICE_POS.y, z = SPECIAL_DICE_POS.z, stackpos = stackpos}
            local thing = getThingFromPos(checkPos)
            
            if thing and thing.itemid == DICE_ID then
                dicePos = {x = SPECIAL_DICE_POS.x, y = SPECIAL_DICE_POS.y, z = SPECIAL_DICE_POS.z}
                diceItem = thing
                break
            end
        end
    else
        -- Buscar dado cercano (radio 5 tiles)
        for x = -5, 5 do
            for y = -5, 5 do
                local checkPos = {
                    x = playerPos.x + x,
                    y = playerPos.y + y,
                    z = playerPos.z
                }
                
                for stackpos = 0, 255 do
                    checkPos.stackpos = stackpos
                    local thing = getThingFromPos(checkPos)
                    
                    if thing and thing.itemid == DICE_ID then
                        dicePos = {x = checkPos.x, y = checkPos.y, z = checkPos.z}
                        diceItem = thing
                        break
                    end
                end
                
                if dicePos then
                    break
                end
            end
            
            if dicePos then
                break
            end
        end
    end
    
    if not dicePos then
        return true
    end
    
    -- Buscar crystal coins en lockers alrededor del dado
    local totalBet = 0
    local coinsToRemove = {}
    
    for dx = -2, 2 do
        for dy = -2, 2 do
            local searchPos = {
                x = dicePos.x + dx,
                y = dicePos.y + dy,
                z = dicePos.z
            }
            
            -- Buscar en todos los stackpos
            for stackpos = 0, 255 do
                searchPos.stackpos = stackpos
                local item = getThingFromPos(searchPos)
                
                if item and item.itemid then
                    -- Verificar si es un locker válido
                    local isValidLocker = false
                    for _, lockerId in ipairs(LOCKER_IDS) do
                        if item.itemid == lockerId then
                            isValidLocker = true
                            break
                        end
                    end
                    
                    if isValidLocker then
                        -- Buscar crystal coins ENCIMA del locker
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
    
    -- Verificar apuesta mínima
    if totalBet < MIN_BET then
        return true
    end
    
    -- Tirar dado (1-8)
    local diceRoll = math.random(1, 8)
    
    -- Determinar si es LOW (1-4) o HIGH (5-8)
    local resultType = diceRoll <= 4 and "LOW" or "HIGH"
    local playerBet = bet == "H" and "HIGH" or "LOW"
    
    -- Verificar si ganó
    local won = (playerBet == resultType)
    
    -- Animar dado
    doSendMagicEffect(dicePos, CONST_ME_CRAPS)
    
    -- Remover todas las monedas apostadas
    for _, coin in ipairs(coinsToRemove) do
        doRemoveItem(coin.uid, coin.count)
    end
    
    if won then
        -- GANÓ: Doble menos 10%
        local grossWin = totalBet * 2
        local commission = math.floor(grossWin * HOUSE_EDGE)
        local netWin = grossWin - commission
        
        -- Dar monedas al jugador
        doPlayerAddItem(cid, CRYSTAL_COIN_ID, netWin)
        
        -- Efectos y mensaje
        doSendMagicEffect(getCreaturePosition(cid), CONST_ME_FIREATTACK)
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Ganaste " .. netWin .. " coins.")
        
    else
        -- PERDIÓ: Pierde todo
        doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "Perdiste.")
    end
    
    return true
end
