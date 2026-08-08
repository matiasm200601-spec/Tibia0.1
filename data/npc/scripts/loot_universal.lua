-- Loot Buyer Universal - Compra TODOS los items del juego
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)            npcHandler:onCreatureAppear(cid)        end
function onCreatureDisappear(cid)         npcHandler:onCreatureDisappear(cid)     end
function onCreatureSay(cid, type, msg)    npcHandler:onCreatureSay(cid, type, msg) end
function onThink()                        npcHandler:onThink()                     end

-- Porcentaje del precio de venta (50% = vendemos a mitad de precio)
local SELL_PERCENTAGE = 50

-- Items que NO se pueden vender (items especiales del servidor)
local BLACKLIST = {
    -- Agrega aquí IDs de items que no quieres que se vendan
    -- Ejemplo: [2195] = true, -- boots of haste
}

function greetCallback(cid)
    npcHandler:say("Hola " .. getCreatureName(cid) .. "! Te compro CUALQUIER item que tengas. Di {trade} para vender o {ayuda} para mas informacion.", cid)
    return true
end

function creatureSayCallback(cid, type, msg)
    if not npcHandler:isFocused(cid) then
        return false
    end
    
    msg = msg:lower()
    
    if msgcontains(msg, 'ayuda') or msgcontains(msg, 'help') then
        npcHandler:say("Te compro TODOS los items del juego al " .. SELL_PERCENTAGE .. "% de su valor. Di {trade} para abrir la ventana de comercio y vendeme lo que quieras!", cid)
        return true
        
    elseif msgcontains(msg, 'trade') or msgcontains(msg, 'comercio') or msgcontains(msg, 'vender') then
        -- Usar el sistema de comercio estándar con un callback personalizado
        npcHandler:say("Selecciona los items que quieres venderme!", cid)
        openShopWindow(cid, getAllSellableItems(), 
            function(cid, itemid, subType, amount, ignoreCap, inBackpacks)
                return onBuy(cid, itemid, subType, amount, ignoreCap, inBackpacks)
            end,
            function(cid, itemid, subType, amount, ignoreCap, inBackpacks)
                return onSell(cid, itemid, subType, amount, ignoreCap, inBackpacks)
            end
        )
        return true
    end
    
    return true
end

function getAllSellableItems()
    local items = {}
    -- Generar lista de todos los items vendibles
    -- En un sistema real, esto cargaría desde items.xml
    -- Por ahora, usamos un rango de IDs común
    for itemid = 2000, 13000 do
        if not BLACKLIST[itemid] then
            local itemType = getItemInfo(itemid)
            if itemType then
                table.insert(items, {
                    id = itemid,
                    buy = -1, -- no compramos (no vendemos al jugador)
                    sell = math.max(1, math.floor((itemType.worth or 0) * SELL_PERCENTAGE / 100)),
                    name = itemType.name or "Item"
                })
            end
        end
    end
    return items
end

function onBuy(cid, itemid, subType, amount, ignoreCap, inBackpacks)
    -- No vendemos items al jugador
    return false
end

function onSell(cid, itemid, subType, amount, ignoreCap, inBackpacks)
    if BLACKLIST[itemid] then
        npcHandler:say("Lo siento, no puedo comprar ese item.", cid)
        return false
    end
    
    local itemType = getItemInfo(itemid)
    if not itemType then
        return false
    end
    
    local price = math.max(1, math.floor((itemType.worth or 1) * SELL_PERCENTAGE / 100))
    local totalPrice = price * amount
    
    -- Verificar que el jugador tenga el item
    if doPlayerRemoveItem(cid, itemid, amount, subType) then
        doPlayerAddMoney(cid, totalPrice)
        npcHandler:say("Aqui tienes " .. totalPrice .. " gold por " .. amount .. " " .. (itemType.name or "item") .. ".", cid)
        return true
    else
        npcHandler:say("No tienes suficientes items.", cid)
        return false
    end
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
