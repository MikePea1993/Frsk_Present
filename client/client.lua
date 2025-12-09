local isUIOpen = false
local currentEmptyPresentId = nil
local currentChristmasPresentId = nil
local currentMetadata = nil

local function DebugPrint(message)
    if Config.Debug then
        print("^3[Frsk_Present DEBUG]^7 " .. message)
    end
end

RegisterNetEvent('frsk_present:openCreateUI')
AddEventHandler('frsk_present:openCreateUI', function(itemId, inventory)
    if isUIOpen then return end

    currentEmptyPresentId = itemId
    currentChristmasPresentId = nil
    isUIOpen = true

    DebugPrint("Opening CREATE UI with " .. #inventory .. " items")

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openUI",
        mode = "create",
        inventory = inventory,
        mailStamp = Config.MailStamp
    })
end)

RegisterNetEvent('frsk_present:openViewUI')
AddEventHandler('frsk_present:openViewUI', function(presentId, metadata)
    if isUIOpen then return end

    currentChristmasPresentId = presentId
    currentEmptyPresentId = nil
    currentMetadata = metadata
    isUIOpen = true

    DebugPrint("Opening VIEW UI for present from " .. (metadata.fromName or "Unknown"))

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openUI",
        mode = "view",
        metadata = metadata,
        mailStamp = Config.MailStamp
    })
end)

RegisterNetEvent('frsk_present:openedPresent')
AddEventHandler('frsk_present:openedPresent', function(metadata)
    local giftText = metadata.giftItemLabel or metadata.giftItem
    if metadata.giftType ~= "weapon" and metadata.giftAmount and metadata.giftAmount > 1 then
        giftText = giftText .. " x" .. metadata.giftAmount
    end
    local message = "You received: " .. giftText .. " from " .. (metadata.fromName or "Unknown")
    Bridge.NotifyRightTip(message, 5000)
end)

function CloseUI()
    isUIOpen = false
    currentEmptyPresentId = nil
    currentChristmasPresentId = nil
    currentMetadata = nil
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "closeUI"
    })
end

RegisterNUICallback('closeUI', function(data, cb)
    CloseUI()
    cb('ok')
end)

RegisterNUICallback('createPresent', function(data, cb)
    if not data.toName or data.toName == "" then
        Bridge.NotifyRightTip(Config.Notifications.MissingFields, 4000)
        cb('error')
        return
    end

    if not data.fromName or data.fromName == "" then
        Bridge.NotifyRightTip(Config.Notifications.MissingFields, 4000)
        cb('error')
        return
    end

    if not data.selectedItem or data.selectedItem == "" then
        Bridge.NotifyRightTip(Config.Notifications.NoItemSelected, 4000)
        cb('error')
        return
    end

    TriggerServerEvent('frsk_present:createPresent', {
        emptyPresentId = currentEmptyPresentId,
        toName = data.toName,
        fromName = data.fromName,
        giftType = data.selectedType or "item",
        giftItem = data.selectedItem,
        giftItemLabel = data.selectedItemLabel,
        giftId = data.selectedId,
        giftAmount = data.selectedAmount
    })

    CloseUI()
    cb('ok')
end)

RegisterNUICallback('openPresent', function(data, cb)
    if not currentChristmasPresentId or not currentMetadata then
        cb('error')
        return
    end

    TriggerServerEvent('frsk_present:openPresent', currentChristmasPresentId, currentMetadata)

    CloseUI()
    cb('ok')
end)

RegisterNetEvent('frsk_present:closeUI')
AddEventHandler('frsk_present:closeUI', function()
    CloseUI()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if isUIOpen then
            CloseUI()
        end
    end
end)
