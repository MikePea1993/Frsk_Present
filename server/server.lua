local function DebugPrint(message)
    if Config.Debug then
        print("^3[Frsk_Present DEBUG]^7 " .. message)
    end
end

CreateThread(function()
    while Bridge.GetFramework() == nil do
        Wait(100)
    end

    local framework = Bridge.GetFramework()
    DebugPrint("Initializing with " .. framework .. " framework")

    Bridge.RegisterUsableItem(Config.Items.EmptyPresent, function(data)
        local source = data.source
        local itemId = data.item.id

        DebugPrint("Player " .. source .. " used empty_present (ID: " .. tostring(itemId) .. ")")

        Bridge.CloseInventory(source)

        local giftableItems = {}

        Bridge.GetUserInventoryItems(source, function(inventory)
            for _, item in pairs(inventory) do
                if item.name ~= Config.Items.EmptyPresent and item.name ~= Config.Items.ChristmasPresent then
                    table.insert(giftableItems, {
                        type = "item",
                        name = item.name,
                        label = item.label,
                        count = item.count,
                        id = item.id
                    })
                end
            end

            Bridge.GetUserInventoryWeapons(source, function(weapons)
                if weapons then
                    for _, weapon in pairs(weapons) do
                        table.insert(giftableItems, {
                            type = "weapon",
                            name = weapon.name,
                            label = weapon.label or weapon.name,
                            count = 1,
                            id = weapon.id,
                            weaponData = {
                                name = weapon.name,
                                ammo = weapon.ammo or {},
                                components = weapon.components or {},
                                serial_number = weapon.serial_number,
                                custom_label = weapon.custom_label,
                                custom_desc = weapon.custom_desc
                            }
                        })
                    end
                end

                Bridge.GetUserAmmo(source, function(ammoData)
                    if ammoData then
                        for ammoType, amount in pairs(ammoData) do
                            if amount > 0 then
                                local ammoLabel = ammoType:gsub("AMMO_", ""):gsub("_", " ")
                                ammoLabel = ammoLabel:sub(1,1):upper() .. ammoLabel:sub(2):lower()

                                table.insert(giftableItems, {
                                    type = "ammo",
                                    name = ammoType,
                                    label = ammoLabel .. " Ammo",
                                    count = amount,
                                    id = ammoType
                                })
                            end
                        end
                    end

                    DebugPrint("Sending " .. #giftableItems .. " giftable items to UI (items, weapons, ammo)")

                    TriggerClientEvent('frsk_present:openCreateUI', source, itemId, giftableItems)
                end)
            end)
        end)
    end)

    Bridge.RegisterUsableItem(Config.Items.ChristmasPresent, function(data)
        local source = data.source
        local metadata = data.item.metadata
        local presentId = data.item.id

        DebugPrint("Player " .. source .. " used christmas_present (ID: " .. tostring(presentId) .. ")")

        Bridge.CloseInventory(source)

        local giftData = metadata.componentshash or metadata

        if giftData and giftData.giftType then
            TriggerClientEvent('frsk_present:openViewUI', source, presentId, giftData)
            DebugPrint("Opening present view UI")
        else
            Bridge.Notify(source, "This present appears to be empty...", 4000)
        end
    end)
end)

RegisterServerEvent('frsk_present:createPresent')
AddEventHandler('frsk_present:createPresent', function(data)
    local source = source

    if not data.emptyPresentId or not data.giftType then
        DebugPrint("Invalid data received for createPresent")
        return
    end

    DebugPrint("Creating present - Type: " .. data.giftType .. " | Gift: " .. (data.giftItem or "unknown") .. " | To: " .. data.toName .. " | From: " .. data.fromName)

    local function createPresentWithMetadata(metadata)
        Bridge.SubItemID(source, data.emptyPresentId)
        Bridge.AddItem(source, Config.Items.ChristmasPresent, 1, metadata)
        Bridge.Notify(source, Config.Notifications.PresentCreated, 4000)
        DebugPrint("Present created successfully!")
    end

    if data.giftType == "item" then
        local itemAmount = data.giftAmount or 1

        Bridge.GetItemByName(source, data.giftItem, function(item)
            if not item or item.count < itemAmount then
                Bridge.Notify(source, Config.Notifications.ItemNotFound, 4000)
                return
            end

            Bridge.SubItem(source, data.giftItem, itemAmount)

            local giftData = {
                toName = data.toName,
                fromName = data.fromName,
                giftType = "item",
                giftItem = data.giftItem,
                giftItemLabel = data.giftItemLabel or data.giftItem,
                giftAmount = itemAmount
            }

            local metadata = {
                description = "To: " .. data.toName .. "<br>From: " .. data.fromName,
                componentshash = giftData
            }

            createPresentWithMetadata(metadata)
        end)

    elseif data.giftType == "weapon" then
        local weaponId = tonumber(data.giftId) or data.giftId

        if not weaponId then
            DebugPrint("Invalid weapon ID: " .. tostring(data.giftId))
            Bridge.Notify(source, Config.Notifications.ItemNotFound, 4000)
            return
        end

        Bridge.GetUserInventoryWeapons(source, function(weapons)
            local weapon = nil
            if weapons then
                for _, w in pairs(weapons) do
                    if w.id == weaponId then
                        weapon = w
                        break
                    end
                end
            end

            if not weapon then
                DebugPrint("Weapon not found with ID: " .. tostring(weaponId))
                Bridge.Notify(source, Config.Notifications.ItemNotFound, 4000)
                return
            end

            DebugPrint("Full weapon object: " .. json.encode(weapon))

            Bridge.GetWeaponComponents(source, weaponId, function(components)
                DebugPrint("Fetched weapon components: " .. json.encode(components or {}))

                local weaponData = {
                    name = weapon.name,
                    ammo = weapon.ammo or {},
                    components = components or {},
                    serial_number = weapon.serial_number,
                    custom_label = weapon.custom_label,
                    custom_desc = weapon.custom_desc,
                    quality = weapon.quality
                }

                DebugPrint("Storing weapon components: " .. json.encode(weaponData.components))
                DebugPrint("Storing weapon ammo: " .. json.encode(weaponData.ammo))

                Bridge.SubWeapon(source, weaponId)

                local giftData = {
                    toName = data.toName,
                    fromName = data.fromName,
                    giftType = "weapon",
                    giftItem = weapon.name,
                    giftItemLabel = data.giftItemLabel or weapon.label or weapon.name,
                    weaponData = weaponData
                }

                local metadata = {
                    description = "To: " .. data.toName .. "<br>From: " .. data.fromName,
                    componentshash = giftData
                }

                createPresentWithMetadata(metadata)
            end)
        end)

    elseif data.giftType == "ammo" then
        local ammoType = data.giftItem
        local ammoAmount = data.giftAmount or 1

        Bridge.GetUserAmmo(source, function(ammoData)
            if not ammoData or not ammoData[ammoType] or ammoData[ammoType] < ammoAmount then
                Bridge.Notify(source, Config.Notifications.ItemNotFound, 4000)
                return
            end

            Bridge.SubBullets(source, ammoType, ammoAmount)

            local giftData = {
                toName = data.toName,
                fromName = data.fromName,
                giftType = "ammo",
                giftItem = ammoType,
                giftItemLabel = data.giftItemLabel or ammoType,
                giftAmount = ammoAmount
            }

            local metadata = {
                description = "To: " .. data.toName .. "<br>From: " .. data.fromName,
                componentshash = giftData
            }

            createPresentWithMetadata(metadata)
        end)
    else
        DebugPrint("Unknown gift type: " .. tostring(data.giftType))
        Bridge.Notify(source, "Invalid gift type!", 4000)
    end
end)

RegisterServerEvent('frsk_present:openPresent')
AddEventHandler('frsk_present:openPresent', function(presentId, giftData)
    local source = source

    if not presentId then
        DebugPrint("Invalid presentId for openPresent")
        return
    end

    if not giftData or not giftData.giftType then
        Bridge.Notify(source, "This present appears to be empty...", 4000)
        return
    end

    Bridge.SubItemID(source, presentId)

    if giftData.giftType == "item" then
        local amount = giftData.giftAmount or 1
        Bridge.AddItem(source, giftData.giftItem, amount)
        DebugPrint("Present opened! Player received item: " .. giftData.giftItem .. " x" .. amount)

    elseif giftData.giftType == "weapon" then
        local weaponData = giftData.weaponData or {}
        DebugPrint("Retrieved weapon components: " .. json.encode(weaponData.components or {}))
        DebugPrint("Retrieved weapon ammo: " .. json.encode(weaponData.ammo or {}))

        Bridge.CreateWeapon(source, weaponData, function(success)
            if success then
                DebugPrint("Present opened! Player received weapon: " .. (weaponData.name or giftData.giftItem))
            end
        end)

    elseif giftData.giftType == "ammo" then
        local amount = giftData.giftAmount or 1
        Bridge.AddBullets(source, giftData.giftItem, amount)
        DebugPrint("Present opened! Player received ammo: " .. giftData.giftItem .. " x" .. amount)
    end

    TriggerClientEvent('frsk_present:openedPresent', source, giftData)
end)

print("^2[Frsk_Present]^7 Christmas Present script loaded successfully!")
