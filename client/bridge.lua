Bridge = {}

local Framework = nil
local Core = nil

CreateThread(function()
    if GetResourceState('vorp_core') == 'started' then
        Framework = 'VORP'
        Core = exports.vorp_core:GetCore()
        print("^2[Frsk_Present]^7 Client detected VORP Framework")
    elseif GetResourceState('rsg-core') == 'started' then
        Framework = 'RSG'
        Core = exports['rsg-core']:GetCoreObject()
        print("^2[Frsk_Present]^7 Client detected RSG Framework")
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

function Bridge.NotifyRightTip(message, duration)
    duration = duration or 4000
    if Framework == 'VORP' then
        Core.NotifyRightTip(message, duration)
    elseif Framework == 'RSG' then
        TriggerEvent('rsg-core:Notify', message, 'primary', duration)
    end
end

function Bridge.Notify(message, notifyType, duration)
    duration = duration or 4000
    notifyType = notifyType or 'primary'
    if Framework == 'VORP' then
        Core.NotifyRightTip(message, duration)
    elseif Framework == 'RSG' then
        TriggerEvent('rsg-core:Notify', message, notifyType, duration)
    end
end
