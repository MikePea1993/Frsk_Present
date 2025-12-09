Bridge = {}

local Framework = nil
local Core = nil

CreateThread(function()
    if GetResourceState('vorp_core') == 'started' then
        Framework = 'VORP'
        Core = exports.vorp_core:GetCore()
        print("^2[Frsk_Present]^7 Detected VORP Framework")
    elseif GetResourceState('rsg-core') == 'started' then
        Framework = 'RSG'
        Core = exports['rsg-core']:GetCoreObject()
        print("^2[Frsk_Present]^7 Detected RSG Framework")
    else
        print("^1[Frsk_Present]^7 ERROR: No supported framework detected!")
    end
end)

function Bridge.GetFramework()
    return Framework
end

function Bridge.GetCore()
    return Core
end

function Bridge.RegisterUsableItem(itemName, callback)
    if Framework == 'VORP' then
        exports.vorp_inventory:registerUsableItem(itemName, function(data)
            callback({
                source = data.source,
                item = data.item
            })
        end, "frsk_present")
    elseif Framework == 'RSG' then
        Core.Functions.CreateUseableItem(itemName, function(source, item)
            callback({
                source = source,
                item = {
                    id = item.slot,
                    name = item.name,
                    label = item.label,
                    metadata = item.info or {}
                }
            })
        end)
    end
end

function Bridge.CloseInventory(source)
    if Framework == 'VORP' then
        exports.vorp_inventory:closeInventory(source)
    elseif Framework == 'RSG' then
        exports['rsg-inventory']:CloseInventory(source)
    end
end

function Bridge.GetUserInventoryItems(source, callback)
    if Framework == 'VORP' then
        exports.vorp_inventory:getUserInventoryItems(source, function(inventory)
            local items = {}
            for _, item in pairs(inventory) do
                table.insert(items, {
                    name = item.name,
                    label = item.label,
                    count = item.count,
                    id = item.id,
                    slot = item.id,
                    metadata = item.metadata or {}
                })
            end
            callback(items)
        end)
    elseif Framework == 'RSG' then
        local Player = Core.Functions.GetPlayer(source)
        if not Player then callback({}) return end

        local items = {}
        for slot, item in pairs(Player.PlayerData.items or {}) do
            if item and item.type ~= 'weapon' then
                table.insert(items, {
                    name = item.name,
                    label = item.label,
                    count = item.amount,
                    id = slot,
                    slot = slot,
                    metadata = item.info or {}
                })
            end
        end
        callback(items)
    end
end

function Bridge.GetUserInventoryWeapons(source, callback)
    if Framework == 'VORP' then
        exports.vorp_inventory:getUserInventoryWeapons(source, function(weapons)
            local weaponList = {}
            if weapons then
                for _, weapon in pairs(weapons) do
                    table.insert(weaponList, {
                        id = weapon.id,
                        name = weapon.name,
                        label = weapon.label or weapon.name,
                        ammo = weapon.ammo or {},
                        serial_number = weapon.serial_number,
                        custom_label = weapon.custom_label,
                        custom_desc = weapon.custom_desc
                    })
                end
            end
            callback(weaponList)
        end)
    elseif Framework == 'RSG' then
        local Player = Core.Functions.GetPlayer(source)
        if not Player then callback({}) return end

        local weapons = {}
        for slot, item in pairs(Player.PlayerData.items or {}) do
            if item and item.type == 'weapon' then
                local info = item.info or {}
                table.insert(weapons, {
                    id = slot,
                    name = item.name,
                    label = item.label or item.name,
                    ammo = {},
                    serial_number = info.serie,
                    custom_label = info.custom_label,
                    custom_desc = info.custom_desc,
                    quality = info.quality or 100,
                    components = info.componentshash or {}
                })
            end
        end
        callback(weapons)
    end
end

function Bridge.GetWeaponComponents(source, weaponId, callback)
    if Framework == 'VORP' then
        exports.vorp_inventory:getWeaponComponents(source, weaponId, function(components)
            callback(components or {})
        end)
    elseif Framework == 'RSG' then
        local Player = Core.Functions.GetPlayer(source)
        if not Player then callback({}) return end

        local item = Player.PlayerData.items[weaponId]
        if item and item.info then
            callback(item.info.componentshash or {})
        else
            callback({})
        end
    end
end

function Bridge.GetItemByName(source, itemName, callback)
    if Framework == 'VORP' then
        exports.vorp_inventory:getItemByName(source, itemName, function(item)
            if item then
                callback({
                    name = item.name,
                    label = item.label,
                    count = item.count,
                    id = item.id,
                    metadata = item.metadata or {}
                })
            else
                callback(nil)
            end
        end)
    elseif Framework == 'RSG' then
        local item = exports['rsg-inventory']:GetItemByName(source, itemName)
        if item then
            callback({
                name = item.name,
                label = item.label,
                count = item.amount,
                id = item.slot,
                metadata = item.info or {}
            })
        else
            callback(nil)
        end
    end
end

function Bridge.AddItem(source, itemName, amount, metadata)
    if Framework == 'VORP' then
        exports.vorp_inventory:addItem(source, itemName, amount, metadata)
    elseif Framework == 'RSG' then
        exports['rsg-inventory']:AddItem(source, itemName, amount, nil, metadata)
    end
end

function Bridge.SubItem(source, itemName, amount)
    if Framework == 'VORP' then
        exports.vorp_inventory:subItem(source, itemName, amount)
    elseif Framework == 'RSG' then
        exports['rsg-inventory']:RemoveItem(source, itemName, amount)
    end
end

function Bridge.SubItemID(source, itemId)
    if Framework == 'VORP' then
        exports.vorp_inventory:subItemID(source, itemId)
    elseif Framework == 'RSG' then
        local item = exports['rsg-inventory']:GetItemBySlot(source, itemId)
        if item then
            exports['rsg-inventory']:RemoveItem(source, item.name, 1, itemId)
        end
    end
end

function Bridge.SubWeapon(source, weaponId)
    if Framework == 'VORP' then
        exports.vorp_inventory:subWeapon(source, weaponId)
    elseif Framework == 'RSG' then
        local item = exports['rsg-inventory']:GetItemBySlot(source, weaponId)
        if item then
            exports['rsg-inventory']:RemoveItem(source, item.name, 1, weaponId)
        end
    end
end

function Bridge.CreateWeapon(source, weaponData, callback)
    if Framework == 'VORP' then
        exports.vorp_inventory:createWeapon(
            source,
            weaponData.name,
            weaponData.ammo or {},
            {},
            weaponData.components or {},
            function(success)
                if callback then callback(success) end
            end,
            nil,
            weaponData.serial_number,
            weaponData.custom_label,
            weaponData.custom_desc
        )
    elseif Framework == 'RSG' then
        local info = {
            serie = weaponData.serial_number or Bridge.GenerateSerial(),
            quality = weaponData.quality or 100,
            componentshash = weaponData.components or {},
            custom_label = weaponData.custom_label,
            custom_desc = weaponData.custom_desc
        }

        local success = exports['rsg-inventory']:AddItem(source, weaponData.name, 1, nil, info)
        if callback then callback(success) end
    end
end

function Bridge.GetUserAmmo(source, callback)
    if Framework == 'VORP' then
        exports.vorp_inventory:getUserAmmo(source, function(ammoData)
            callback(ammoData or {})
        end)
    elseif Framework == 'RSG' then
        local Player = Core.Functions.GetPlayer(source)
        if not Player then callback({}) return end

        local ammoData = {}
        for _, item in pairs(Player.PlayerData.items or {}) do
            if item and item.name:match("^ammo_") then
                ammoData[item.name:upper()] = (ammoData[item.name:upper()] or 0) + item.amount
            end
        end
        callback(ammoData)
    end
end

function Bridge.AddBullets(source, ammoType, amount)
    if Framework == 'VORP' then
        exports.vorp_inventory:addBullets(source, ammoType, amount)
    elseif Framework == 'RSG' then
        local ammoItemName = ammoType:lower()
        exports['rsg-inventory']:AddItem(source, ammoItemName, amount)
    end
end

function Bridge.SubBullets(source, ammoType, amount)
    if Framework == 'VORP' then
        exports.vorp_inventory:subBullets(source, ammoType, amount)
    elseif Framework == 'RSG' then
        local ammoItemName = ammoType:lower()
        exports['rsg-inventory']:RemoveItem(source, ammoItemName, amount)
    end
end

function Bridge.GenerateSerial()
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local serial = ''
    for i = 1, 10 do
        local idx = math.random(1, #chars)
        serial = serial .. chars:sub(idx, idx)
    end
    return serial
end

function Bridge.Notify(source, message, duration)
    duration = duration or 4000
    if Framework == 'VORP' then
        TriggerClientEvent("vorp:TipRight", source, message, duration)
    elseif Framework == 'RSG' then
        TriggerClientEvent('rsg-core:Notify', source, message, 'primary', duration)
    end
end
