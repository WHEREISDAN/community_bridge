---@diagnostic disable: duplicate-set-field
if GetResourceState('oxide-weather') == 'missing' then return end
Weather = Weather or {}

---This will toggle the players weather/time sync
---@param toggle boolean
---@return nil
Weather.ToggleSync = function(toggle)

end

Weather.GetResourceName = function()
    return "oxide-weather"
end

---Get the current weather type as a string
---@return string
Weather.GetWeather = function()
    return GlobalState['oxide:weather'] or 'CLEAR'
end

---Get the current in-game time
---@return table { hour: number, minute: number }
Weather.GetTime = function()
    return GlobalState['oxide:time'] or { hour = 12, minute = 0 }
end

return Weather
