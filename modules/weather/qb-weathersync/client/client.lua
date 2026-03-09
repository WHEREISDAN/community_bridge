---@diagnostic disable: duplicate-set-field
if GetResourceState('qb-weathersync') == 'missing' then return end
Weather = Weather or {}

local trackedWeather = 'EXTRASUNNY'

AddEventHandler('qb-weathersync:client:SyncWeather', function(NewWeather)
    trackedWeather = NewWeather
end)

TriggerServerEvent('qb-weathersync:server:RequestStateSync')

---This will toggle the players weather/time sync
---@param toggle boolean
---@return nil
Weather.ToggleSync = function(toggle)
    if toggle then
        TriggerEvent("qb-weathersync:client:EnableSync")
    else
        TriggerEvent("qb-weathersync:client:DisableSync")
    end
end

Weather.GetResourceName = function()
    return "qb-weathersync"
end

---Get the current weather type as a string
---@return string
Weather.GetWeather = function()
    return trackedWeather
end

---Get the current in-game time
---@return table { hour: number, minute: number }
Weather.GetTime = function()
    return { hour = GetClockHours(), minute = GetClockMinutes() }
end

return Weather