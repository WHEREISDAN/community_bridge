---@diagnostic disable: duplicate-set-field
if GetResourceState('night_natural_disasters') == 'missing' then return end
Weather = Weather or {}

---This will toggle the players weather/time sync
---@param toggle boolean
---@return nil
Weather.ToggleSync = function(toggle)
    exports['night_natural_disasters']:PauseSynchronization(not toggle)
end

Weather.GetResourceName = function()
    return "night_natural_disasters"
end

---Get the current weather type as a string
---@return string
Weather.GetWeather = function()
    return exports['night_natural_disasters']:GetCurrentWeather() or 'CLEAR'
end

---Get the current in-game time
---@return table { hour: number, minute: number }
Weather.GetTime = function()
    return { hour = GetClockHours(), minute = GetClockMinutes() }
end

return Weather
