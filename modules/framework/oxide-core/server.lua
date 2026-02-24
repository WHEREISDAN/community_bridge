---@diagnostic disable: duplicate-set-field
if GetResourceState('oxide-core') ~= 'started' then return end

Framework = Framework or {}

local Oxide = exports['oxide-core']:Core()

---@description This will get the name of the in use resource.
---@return string
Framework.GetResourceName = function()
    return 'oxide-core'
end

---@description This will return the name of the framework in use.
---@return string
Framework.GetFrameworkName = function()
    print("[Community Bridge] Warning: Framework.GetFrameworkName is deprecated, use Framework.GetResourceName instead.")
    return Framework.GetResourceName()
end

---@description This will return if the player is an admin in the framework.
---@param src any
---@return boolean
Framework.GetIsFrameworkAdmin = function(src)
    if not src then return false end
    return IsPlayerAceAllowed(tostring(src), 'command')
end

---@description Returns the player data of the specified source in the framework default format.
---@param src any
---@return table|nil
Framework.GetPlayer = function(src)
    return Oxide.Functions.GetPlayer(src)
end

---@description This will return the citizen ID of the player.
---@param src number
---@return string|nil
Framework.GetPlayerIdentifier = function(src)
    local player = Oxide.Functions.GetPlayer(src)
    if not player then return end
    local character = player.GetCharacter()
    if not character then return end
    return tostring(character.charId)
end

---@description Returns the first and last name of the player.
---@param src number
---@return string|nil, string|nil
Framework.GetPlayerName = function(src)
    local player = Oxide.Functions.GetPlayer(src)
    if not player then return end
    local character = player.GetCharacter()
    if not character then return end
    return character.firstName, character.lastName
end

---@description Returns the player date of birth.
---@param src number
---@return string|nil
Framework.GetPlayerDob = function(src)
    local player = Oxide.Functions.GetPlayer(src)
    if not player then return end
    local character = player.GetCharacter()
    if not character then return end
    local metadata = character.GetMetadata()
    return metadata and metadata.dob or nil
end

---@description Returns the phone number of the player.
---@param src number
---@return string|nil
Framework.GetPlayerPhone = function(src)
    if GetResourceState('oxide-phone') ~= 'started' then return end
    local ok, result = pcall(exports['oxide-phone'].GetPhoneNumber, exports['oxide-phone'], src)
    if ok then return result end
    return nil
end

---@description Returns the gang name of the player (Oxide has no gang system).
---@param src number
---@return string|nil
Framework.GetPlayerGang = function(src)
    return nil
end

---@description This will return the jobs registered in the framework (Oxide has no job system).
---@return table
Framework.GetFrameworkJobs = function()
    return {}
end

---@description This will get a table of player sources that have the specified job name.
---@param job string
---@return table
Framework.GetPlayersByJob = function(job)
    return Framework.GetPlayerSourcesByJob(job) or {}
end

---@description Returns the job data of the player (Oxide has no job system, returns empty defaults).
---@param src number
---@return table
Framework.GetPlayerJobData = function(src)
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
---@param src number
---@return string, string, string, number
Framework.GetPlayerJob = function(src)
    local jobData = Framework.GetPlayerJobData(src)
    return jobData.jobName, jobData.jobLabel, jobData.gradeName, jobData.gradeRank
end

---@description Returns the players duty status (Oxide has no duty system).
---@param src number
---@return boolean
Framework.GetPlayerDuty = function(src)
    return false
end

---@description This will toggle a players duty status (Oxide has no duty system).
---@param src number
---@param status boolean
---@return boolean
Framework.SetPlayerDuty = function(src, status)
    return false
end

---@description Sets the player's job (Oxide has no job system).
---@param src number
---@param name string
---@param grade string
---@return boolean
Framework.SetPlayerJob = function(src, name, grade)
    return false
end

---@description This will return a table of all logged in players.
---@return table
Framework.GetPlayers = function()
    local players = Oxide.Functions.GetPlayers()
    local playerList = {}
    for _, player in pairs(players) do
        table.insert(playerList, player.source)
    end
    return playerList
end

-- ============================================================================
-- Account Balance (via oxide-accounts)
-- ============================================================================

---@description Resolves charId from source for account operations.
---@param src number
---@return number|nil
local function GetCharId(src)
    local player = Oxide.Functions.GetPlayer(src)
    if not player then return nil end
    local character = player.GetCharacter()
    if not character then return nil end
    return character.charId
end

---@description This will add money based on the type of account.
---@param src number
---@param _type string
---@param amount number
---@return boolean
Framework.AddAccountBalance = function(src, _type, amount)
    if amount <= 0 then return false end
    local charId = GetCharId(src)
    if not charId then return false end
    if _type == 'money' then _type = 'cash' end
    local balance = exports['oxide-accounts']:AddMoney(charId, _type, amount, 'bridge', 'Community Bridge')
    return balance ~= nil
end

---@description This will remove money based on the type of account.
---@param src number
---@param _type string
---@param amount number
---@return boolean
Framework.RemoveAccountBalance = function(src, _type, amount)
    if amount <= 0 then return false end
    local charId = GetCharId(src)
    if not charId then return false end
    if _type == 'money' then _type = 'cash' end
    local balance = exports['oxide-accounts']:RemoveMoney(charId, _type, amount, 'bridge', 'Community Bridge')
    return balance ~= nil
end

---@description This will get money based on the type of account.
---@param src number
---@param _type string
---@return number
Framework.GetAccountBalance = function(src, _type)
    local charId = GetCharId(src)
    if not charId then return 0 end
    if _type == 'money' then _type = 'cash' end
    return exports['oxide-accounts']:GetBalance(charId, _type) or 0
end

-- ============================================================================
-- Metadata
-- ============================================================================

---@description Gets the specified metadata key from the player's character data.
---@param src number
---@param metadata string
---@return any|nil
Framework.GetPlayerMetadata = function(src, metadata)
    local player = Oxide.Functions.GetPlayer(src)
    if not player then return nil end
    local character = player.GetCharacter()
    if not character then return nil end
    return character.GetMetadata(metadata)
end

---@description Sets the specified metadata key on the player's character data.
---@param src number
---@param metadata string
---@param value any
---@return boolean|nil
Framework.SetPlayerMetadata = function(src, metadata, value)
    local player = Oxide.Functions.GetPlayer(src)
    if not player then return nil end
    local character = player.GetCharacter()
    if not character then return nil end
    character.SetMetadata(metadata, value)
    return true
end

-- ============================================================================
-- Hunger / Thirst / Stress (via oxide-needs)
-- ============================================================================

---@description This will get the hunger of a player.
---@param src number
---@return number
Framework.GetHunger = function(src)
    if GetResourceState('oxide-needs') ~= 'started' then return 100 end
    local ok, result = pcall(exports['oxide-needs'].GetNeed, exports['oxide-needs'], src, 'hunger')
    if ok and result then return math.floor(result + 0.5) end
    return 100
end

---@description This will get the thirst of a player.
---@param src number
---@return number
Framework.GetThirst = function(src)
    if GetResourceState('oxide-needs') ~= 'started' then return 100 end
    local ok, result = pcall(exports['oxide-needs'].GetNeed, exports['oxide-needs'], src, 'thirst')
    if ok and result then return math.floor(result + 0.5) end
    return 100
end

---@description Adds the specified value to the player's stress level.
---@param src number
---@param value number
---@return number|nil
Framework.AddStress = function(src, value)
    if GetResourceState('oxide-needs') ~= 'started' then return nil end
    local ok, result = pcall(exports['oxide-needs'].ModifyNeed, exports['oxide-needs'], src, 'stress', value)
    if ok then return result end
    return nil
end

---@description Removes the specified value from the player's stress level.
---@param src number
---@param value number
---@return number|nil
Framework.RemoveStress = function(src, value)
    if GetResourceState('oxide-needs') ~= 'started' then return nil end
    local ok, result = pcall(exports['oxide-needs'].ModifyNeed, exports['oxide-needs'], src, 'stress', -value)
    if ok then return result end
    return nil
end

---@description Adds the specified value to the player's hunger level.
---@param src number
---@param value number
---@return number|nil
Framework.AddHunger = function(src, value)
    if GetResourceState('oxide-needs') ~= 'started' then return nil end
    local ok, result = pcall(exports['oxide-needs'].ModifyNeed, exports['oxide-needs'], src, 'hunger', value)
    if ok then return result end
    return nil
end

---@description Adds the specified value to the player's thirst level.
---@param src number
---@param value number
---@return number|nil
Framework.AddThirst = function(src, value)
    if GetResourceState('oxide-needs') ~= 'started' then return nil end
    local ok, result = pcall(exports['oxide-needs'].ModifyNeed, exports['oxide-needs'], src, 'thirst', value)
    if ok then return result end
    return nil
end

-- ============================================================================
-- Death State (via oxide-death)
-- ============================================================================

---@description This will return a boolean if the player is dead or downed.
---@param src number
---@return boolean
Framework.GetIsPlayerDead = function(src)
    if GetResourceState('oxide-death') ~= 'started' then return false end
    local ok, result = pcall(exports['oxide-death'].IsPlayerDead, exports['oxide-death'], src)
    if ok then return result or false end
    return false
end

---@description This will return a boolean if the player is downed.
---@param src number
---@return boolean
Framework.GetIsPlayerDowned = function(src)
    if GetResourceState('oxide-death') ~= 'started' then return false end
    local ok, result = pcall(exports['oxide-death'].IsPlayerDowned, exports['oxide-death'], src)
    if ok then return result or false end
    return false
end

---@description Returns the death state data for the player.
---@param src number
---@return table|nil
Framework.GetDeathState = function(src)
    if GetResourceState('oxide-death') ~= 'started' then return nil end
    local ok, result = pcall(exports['oxide-death'].GetDeathState, exports['oxide-death'], src)
    if ok then return result end
    return nil
end

---@description This will revive a player.
---@param src number
---@return boolean
Framework.RevivePlayer = function(src)
    if GetResourceState('oxide-death') ~= 'started' then return false end
    local ok, result = pcall(exports['oxide-death'].RevivePlayer, exports['oxide-death'], src)
    if ok then return result or false end
    return false
end

---@description This will kill a player.
---@param src number
---@param cause string|nil
---@return boolean
Framework.KillPlayer = function(src, cause)
    if GetResourceState('oxide-death') ~= 'started' then return false end
    local ok, result = pcall(exports['oxide-death'].KillPlayer, exports['oxide-death'], src, cause)
    if ok then return result or false end
    return false
end

---@description This will respawn a player.
---@param src number
---@param coords vector3|nil
---@return boolean
Framework.RespawnPlayer = function(src, coords)
    if GetResourceState('oxide-death') ~= 'started' then return false end
    local ok, result = pcall(exports['oxide-death'].RespawnPlayer, exports['oxide-death'], src, coords)
    if ok then return result or false end
    return false
end

---@description This will down a player.
---@param src number
---@param cause string|nil
---@return boolean
Framework.DownPlayer = function(src, cause)
    if GetResourceState('oxide-death') ~= 'started' then return false end
    local ok, result = pcall(exports['oxide-death'].DownPlayer, exports['oxide-death'], src, cause)
    if ok then return result or false end
    return false
end

-- ============================================================================
-- Inventory (stub - uses oxide-inventory directly if needed)
-- ============================================================================

---@description Returns a table of items matching the specified name.
---@param src number
---@param item string
---@param metadata table|nil
---@return table
Framework.GetItem = function(src, item, metadata)
    return {}
end

---@description This will return a table with the item info.
---@param item string
---@return table
Framework.GetItemInfo = function(item)
    return {}
end

---@description This will return the count of the item in the players inventory.
---@param src number
---@param item string
---@param metadata table|nil
---@return number
Framework.GetItemCount = function(src, item, metadata)
    return 0
end

---@description This will return a boolean if the player has the item.
---@param src number
---@param item string
---@param requiredCount number|nil
---@return boolean
Framework.HasItem = function(src, item, requiredCount)
    return false
end

---@description Returns the entire inventory of the player.
---@param src number
---@return table
Framework.GetPlayerInventory = function(src)
    return {}
end

---@description Returns the specified slot data as a table.
---@param src number
---@param slot number
---@return table
Framework.GetItemBySlot = function(src, slot)
    return {}
end

---@description This will add an item.
---@param src number
---@param item string
---@param count number
---@param slot number|nil
---@param metadata table|nil
---@return boolean
Framework.AddItem = function(src, item, count, slot, metadata)
    return false
end

---@description This will remove an item.
---@param src number
---@param item string
---@param count number
---@param slot number|nil
---@param metadata table|nil
---@return boolean
Framework.RemoveItem = function(src, item, count, slot, metadata)
    return false
end

---@description This will set the metadata of an item.
---@param src number
---@param item string
---@param slot number
---@param metadata table
---@return boolean
Framework.SetMetadata = function(src, item, slot, metadata)
    return false
end

-- ============================================================================
-- Vehicles (stub)
-- ============================================================================

---@description This will get all owned vehicles for the player.
---@param src number
---@return table
Framework.GetOwnedVehicles = function(src)
    return {}
end

---@description Returns whether a vehicle is owned by the player.
---@param src number
---@param plate string
---@return table|boolean
Framework.IsVehicleOwnedByPlayer = function(src, plate)
    return false
end

-- ============================================================================
-- Usable Items (via oxide-core ItemCallbacks)
-- ============================================================================

---@description Registers a usable item with a callback function.
---@param itemName string
---@param cb function
Framework.RegisterUsableItem = function(itemName, cb)
    local func = function(source, item, metadata)
        local itemData = {
            name = itemName,
            metadata = metadata or {},
            slot = 0,
        }
        cb(source, itemData)
    end
    Oxide.ItemCallbacks.Register(itemName, func)
end

-- ============================================================================
-- Commands
-- ============================================================================

Framework.Commands = {}

---@description Adds a command.
---@param name string
---@param help string
---@param arguments table
---@param argsrequired boolean
---@param callback function
---@param permission string
Framework.Commands.Add = function(name, help, arguments, argsrequired, callback, permission, ...)
    RegisterCommand(name, function(source, args, rawCommand)
        if permission and permission ~= '' then
            if not IsPlayerAceAllowed(tostring(source), permission) then
                return
            end
        end
        callback(source, args)
    end, permission and permission ~= '')
end

-- ============================================================================
-- Logout (return to character selection)
-- ============================================================================

---@description Logs the player out of their active character and returns them to character selection.
---@param src number
---@return boolean
Framework.Logout = function(src)
    local player = Oxide.Functions.GetPlayer(src)
    if not player then return false end

    local character = player.GetCharacter()
    if character then
        TriggerEvent('oxide:core:characterUnloading', src, player, character)
    end

    player.SetActiveCharacter(nil)
    TriggerClientEvent('oxide:multichar:logoutComplete', src)
    return true
end

-- ============================================================================
-- Events
-- ============================================================================

---@description Event handler for when a player is loaded (character ready)
AddEventHandler('oxide:core:playerReady', function(source)
    TriggerEvent("community_bridge:Server:OnPlayerLoaded", source)
end)

---@description Event handler for when a character is unloaded (logout to char select)
AddEventHandler('oxide:core:characterUnloaded', function(source)
    TriggerEvent("community_bridge:Server:OnPlayerUnload", source)
end)

---@description Event handler for when a player disconnects
AddEventHandler("playerDropped", function()
    local src = source
    TriggerEvent("community_bridge:Server:OnPlayerUnload", src)
end)

---@description Death event forwarding (oxide-death → bridge events)
if GetResourceState('oxide-death') == 'started' or GetResourceState('oxide-death') == 'starting' then
    AddEventHandler('oxide:death:playerDowned', function(src)
        TriggerEvent("community_bridge:Server:OnPlayerDowned", src)
    end)

    AddEventHandler('oxide:death:playerDied', function(src)
        TriggerEvent("community_bridge:Server:OnPlayerDied", src)
    end)

    AddEventHandler('oxide:death:playerRespawned', function(src)
        TriggerEvent("community_bridge:Server:OnPlayerRespawned", src)
    end)
end

return Framework
