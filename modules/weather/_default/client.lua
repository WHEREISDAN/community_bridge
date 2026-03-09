---@diagnostic disable: duplicate-set-field
Weather = Weather or {}

---This will toggle the players weather/time sync
---@param toggle boolean
---@return nil
Weather.ToggleSync = function(toggle)

end

Weather.GetResourceName = function()
    return "default"
end

local weatherNames = {
    [`EXTRASUNNY`] = 'EXTRASUNNY',
    [`CLEAR`] = 'CLEAR',
    [`NEUTRAL`] = 'NEUTRAL',
    [`SMOG`] = 'SMOG',
    [`FOGGY`] = 'FOGGY',
    [`OVERCAST`] = 'OVERCAST',
    [`CLOUDS`] = 'CLOUDS',
    [`CLEARING`] = 'CLEARING',
    [`RAIN`] = 'RAIN',
    [`THUNDER`] = 'THUNDER',
    [`SNOW`] = 'SNOW',
    [`BLIZZARD`] = 'BLIZZARD',
    [`SNOWLIGHT`] = 'SNOWLIGHT',
    [`XMAS`] = 'XMAS',
    [`HALLOWEEN`] = 'HALLOWEEN',
}

---Get the current weather type as a string
---@return string
Weather.GetWeather = function()
    return weatherNames[GetPrevWeatherType()] or 'CLEAR'
end

---Get the current in-game time
---@return table { hour: number, minute: number }
Weather.GetTime = function()
    return { hour = GetClockHours(), minute = GetClockMinutes() }
end

return Weather