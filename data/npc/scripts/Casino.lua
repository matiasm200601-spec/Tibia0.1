local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local CRYSTAL_COIN_ID = 2160
local MIN_BET = 2
local HOUSE_EDGE_NORMAL = 0.10 -- 10% para apuestas <= 50
local HOUSE_EDGE_HIGH = 0.70 -- 70% para apuestas > 50
local HIGH_BET_THRESHOLD = 50 -- Umbral para comisión alta

function onCreatureAppear(cid)            npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)         npcHandler:onCreatureDisappear(cid)         end
function onCreatureSay(cid, type, msg)    npcHandler:onCreatureSay(cid, type, msg)    end
function onThink()                        npcHandler:onThink()                        end

function processBet(cid, bet)
    local npcPos = getCreaturePosition(getNpcCid())
    
    -- Buscar crystal coins en un radio de 1 tile alrededor del NPC
    local totalBet = 0
    local coinsToRemove = {}
    
    for dx = -1, 1 do
        for dy = -1, 1 do
            local searchPos = {
                x = npcPos.x + dx,
                y = npcPos.y + dy,
                z = npcPos.z
            }
            
            -- Buscar crystal coins en cada posición
            for stackpos = 0, 255 do
                searchPos.stackpos = stackpos
                local item = getThingFromPos(searchPos)
                
                if item and item.uid > 0 and item.itemid == CRYSTAL_COIN_ID then
                    local count = item.type > 0 and item.type or 1
                    totalBet = totalBet + count
                    table.insert(coinsToRemove, {uid = item.uid, count = count})
                elseif not item or item.itemid == 0 then
                    break
                end
            end
        end
    end
    
    -- Verificar apuesta mínima
    if totalBet < MIN_BET then
        npcHandler:say("No veo suficientes crystal coins. Coloca minimo " .. MIN_BET .. " crystal coins cerca de mi.", cid)
        return true
    end
    
    -- Tirar número del 1 al 6 con 50% LOW (1-3) y 50% HIGH (4-6)
    local roll
    if math.random(1, 2) == 1 then
        -- 50% probabilidad: números LOW (1-3)
        roll = math.random(1, 3)
    else
        -- 50% probabilidad: números HIGH (4-6)
        roll = math.random(4, 6)
    end
    
    -- Determinar resultado: 1-3 = LOW, 4-6 = HIGH
    local resultType = roll <= 3 and "l" or "h"
    
    -- Verificar si ganó
    local won = (bet == resultType)
    
    -- Remover todas las monedas apostadas
    for _, coin in ipairs(coinsToRemove) do
        doRemoveItem(coin.uid, coin.count)
    end
    
    -- Anunciar el número
    if won then
        -- GANÓ: Calcular comisión según monto apostado
        local grossWin = totalBet * 2
        local houseEdge = totalBet > HIGH_BET_THRESHOLD and HOUSE_EDGE_HIGH or HOUSE_EDGE_NORMAL
        local commission = math.floor(grossWin * houseEdge)
        local netWin = grossWin - commission
        
        -- Dar monedas al jugador
        doPlayerAddItem(cid, CRYSTAL_COIN_ID, netWin)
        
        -- Efectos y mensaje
        doSendMagicEffect(getCreaturePosition(cid), CONST_ME_FIREATTACK)
        npcHandler:say("Salio el numero " .. roll .. "! Ganaste " .. netWin .. " crystal coins!", cid)
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Ganaste " .. netWin .. " coins.")
    else
        -- PERDIÓ
        doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
        npcHandler:say("Salio el numero " .. roll .. "! Perdiste.", cid)
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "Perdiste.")
    end
    
    return true
end

-- Función para manejar keywords "h" y "l"
function betCallback(cid, message, keywords, parameters, node)
    if not npcHandler:isFocused(cid) then
        return false
    end
    
    local bet = message:lower()
    if bet == "h" or bet == "l" then
        processBet(cid, bet)
        return true
    end
    
    return false
end

-- Registrar keywords simples
keywordHandler:addKeyword({'h'}, betCallback, {})
keywordHandler:addKeyword({'l'}, betCallback, {})

npcHandler:addModule(FocusModule:new())
