---@diagnostic disable: duplicate-set-field
if GetResourceState('oxide-core') ~= 'started' then return end

Framework = Framework or {}

---@description This will get the name of the in use resource.
---@return string
Framework.GetResourceName = function()
    return 'oxide-core'
end

---@description This will get the name of the framework being used.
---@return string
Framework.GetFrameworkName = function()
    print("[Community Bridge] Warning: Framework.GetFrameworkName is deprecated, use Framework.GetResourceName instead.")
    return Framework.GetResourceName()
end

---@description This will return true if the player is loaded, false otherwise.
---@return boolean
Framework.GetIsPlayerLoaded = function()
    return LocalPlayer.state['oxide:character'] ~= nil
end

---@description This will return a table of the player data.
---@return table|nil
Framework.GetPlayerData = function()
    return LocalPlayer.state['oxide:character']
end

---@description This will get the players identifier (charId).
---@return string|nil
Framework.GetPlayerIdentifier = function()
    local char = LocalPlayer.state['oxide:character']
    if not char then return nil end
    return tostring(char.charId)
end

---@description This will get the players name (first and last).
---@return string|nil, string|nil
Framework.GetPlayerName = function()
    local char = LocalPlayer.state['oxide:character']
    if not char then return nil, nil end
    return char.firstName, char.lastName
end

---@description This will get the players birth date.
---@return string|nil
Framework.GetPlayerDob = function()
    local char = LocalPlayer.state['oxide:character']
    if not char then return nil end
    return char.dob
end

---@description This will return the players metadata for the specified metadata key.
---@param metadata string
---@return any|nil
Framework.GetPlayerMetaData = function(metadata)
    local char = LocalPlayer.state['oxide:character']
    if not char then return nil end
    if char.metadata then return char.metadata[metadata] end
    return nil
end

---@description This will send a notification to the player.
---@param message string
---@param _type string|nil
---@param time number|nil
---@return nil
Framework.Notify = function(message, _type, time)
    exports['oxide-core']:Notify(message, _type)
end

---@description This will display the help text message on the screen.
---@param message string
---@param _position string|nil
---@return nil
Framework.ShowHelpText = function(message, _position)
    lib.showTextUI(message, { position = _position })
end

---@description This will hide the help text message on the screen.
---@return nil
Framework.HideHelpText = function()
    lib.hideTextUI()
end

---@description This will return the players money by type (client-side, not secure).
---@param _type string
---@return number
Framework.GetAccountBalance = function(_type)
    return 0
end

---@description This will return the item data for the specified item.
---@param item string
---@return table
Framework.GetItemInfo = function(item)
    return {}
end

---@description This will get the hunger of a player.
---@return number
Framework.GetHunger = function()
    return 100
end

---@description This will get the thirst of a player.
---@return number
Framework.GetThirst = function()
    return 100
end

---@description This will return a table of all the jobs in the framework (Oxide has no job system).
---@return table
Framework.GetFrameworkJobs = function()
    return {}
end

---@description This will return the players job data (Oxide has no job system).
---@return table
Framework.GetPlayerJobData = function()
    return {
        jobName = 'unemployed',
        jobLabel = 'Unemployed',
        gradeName = 'default',
        gradeLabel = 'Default',
        gradeRank = 0,
        boss = false,
        onDuty = false,
    }
end

---@deprecated Returns the job name, label, grade name, and grade level of the player.
---@return string, string, string, number
Framework.GetPlayerJob = function()
    local jobData = Framework.GetPlayerJobData()
    return jobData.jobName, jobData.jobLabel, jobData.gradeName, jobData.gradeRank
end

---@description Will return boolean if the player has the item.
---@param item string
---@param requiredCount number|nil
---@return boolean
Framework.HasItem = function(item, requiredCount)
    return false
end

---@description This will return the item count for the specified item.
---@param item string
---@return number
Framework.GetItemCount = function(item)
    return 0
end

---@description This will return the players inventory.
---@return table
Framework.GetPlayerInventory = function()
    return {}
end

---@description This will get a players dead status.
---@return boolean
Framework.GetIsPlayerDead = function()
    if GetResourceState('oxide-death') ~= 'started' then return false end
    local ok, result = pcall(exports['oxide-death'].IsLocalPlayerDead, exports['oxide-death'])
    if ok then return result or false end
    return false
end

---@description This will get a players downed status.
---@return boolean
Framework.GetIsPlayerDowned = function()
    if GetResourceState('oxide-death') ~= 'started' then return false end
    local ok, result = pcall(exports['oxide-death'].IsLocalPlayerDowned, exports['oxide-death'])
    if ok then return result or false end
    return false
end

---@description Returns the death state data for the local player.
---@return table|nil
Framework.GetDeathState = function()
    if GetResourceState('oxide-death') ~= 'started' then return nil end
    local ok, result = pcall(exports['oxide-death'].GetLocalDeathState, exports['oxide-death'])
    if ok then return result end
    return nil
end

---@description This will return the vehicle properties for the specified vehicle.
---@param vehicle number
---@return table
Framework.GetVehicleProperties = function(vehicle)
    if not vehicle or not DoesEntityExist(vehicle) then return {} end
    return {}
end

---@description This will set the vehicle properties for the specified vehicle.
---@param vehicle number
---@param properties table
---@return boolean
Framework.SetVehicleProperties = function(vehicle, properties)
    return false
end

-- ============================================================================
-- Events
-- ============================================================================

---@description Listen for character load/unload via statebag
AddStateBagChangeHandler('oxide:character', ('player:%s'):format(cache.serverId), function(_, _, value)
    if value ~= nil then
        Wait(500)
        TriggerEvent('community_bridge:Client:OnPlayerLoaded')
    else
        TriggerEvent('community_bridge:Client:OnPlayerUnload')
    end
end)

---@description Handle resource restart: check if player is already loaded
CreateThread(function()
    Wait(1000)
    if LocalPlayer.state['oxide:character'] ~= nil then
        TriggerEvent('community_bridge:Client:OnPlayerLoaded')
    end
end)

return Framework
