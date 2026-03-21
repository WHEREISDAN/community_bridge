---@diagnostic disable: duplicate-set-field

if GetResourceState('oxide-identity') == 'missing' then return end

Clothing = Clothing or {}
Clothing.Players = {}

Callback = Callback or Require("lib/utility/shared/callbacks.lua")

--- Normalize JSON-decoded table keys from strings to numbers
---@param tbl table
---@return table
local function NormalizeKeys(tbl)
    local result = {}
    for k, v in pairs(tbl) do
        result[tonumber(k) or k] = v
    end
    return result
end

--- Internal function to get the full appearance data from oxide-identity's DB tables
---@param src number The server ID of the player
---@return table|nil The player's full appearance data or nil if not found
function Clothing.GetFullAppearanceData(src)
    src = src and tonumber(src)
    assert(src, "src is nil")
    local charId = Bridge.Framework.GetPlayerIdentifier(src)
    if not charId then return end

    if Clothing.Players[charId] then return Clothing.Players[charId] end

    local clothingResult = MySQL.query.await('SELECT * FROM character_clothing WHERE char_id = ?', { charId })
    if not clothingResult or not clothingResult[1] then return end

    local appearanceResult = MySQL.query.await('SELECT model FROM character_appearance WHERE char_id = ?', { charId })

    local components = NormalizeKeys(json.decode(clothingResult[1].components) or {})
    local props = NormalizeKeys(json.decode(clothingResult[1].props) or {})
    local model = appearanceResult and appearanceResult[1] and appearanceResult[1].model or 'mp_m_freemode_01'

    local nativeData = { components = components, props = props }
    local converted = Clothing.ConvertToDefault(nativeData)

    Clothing.Players[charId] = {
        model = model,
        native = nativeData,
        converted = converted
    }

    return Clothing.Players[charId]
end

---@return string
Clothing.GetResourceName = function()
    return 'oxide-identity'
end

--- Retrieves a player's converted appearance data
---@param src number The server ID of the player
---@param fullData boolean Optional - If true, returns the full data object
---@return table|nil
function Clothing.GetAppearance(src, fullData)
    if fullData then
        return Clothing.GetFullAppearanceData(src)
    end
    local completeData = Clothing.GetFullAppearanceData(src)
    if not completeData then return nil end
    return completeData.converted
end

--- Sets a player's appearance based on the provided default-format data
---@param src number The server ID of the player
---@param data table The appearance data in default format
---@param updateBackup boolean Whether to update the backup appearance data
---@param save boolean Whether to persist to database
---@return table|nil The updated player appearance data or nil if failed
function Clothing.SetAppearance(src, data, updateBackup, save)
    src = src and tonumber(src)
    assert(src, "src is nil")
    local charId = Bridge.Framework.GetPlayerIdentifier(src)
    if not charId then return end

    local currentClothing = Clothing.GetFullAppearanceData(src)
    if not currentClothing then return end

    local incoming = Clothing.ConvertFromDefault(data)

    local currentNative = currentClothing.native
    for k, v in pairs(incoming.components or {}) do
        currentNative.components[k] = v
    end
    for k, v in pairs(incoming.props or {}) do
        currentNative.props[k] = v
    end

    if not Clothing.Players[charId].backup or updateBackup then
        Clothing.Players[charId].backup = currentClothing.converted
    end

    Clothing.Players[charId].native = currentNative
    Clothing.Players[charId].converted = Clothing.ConvertToDefault(currentNative)

    if save then
        MySQL.update.await('UPDATE character_clothing SET components = ?, props = ? WHERE char_id = ?', {
            json.encode(currentNative.components),
            json.encode(currentNative.props),
            charId
        })
    end

    TriggerClientEvent('community_bridge:client:SetAppearance', src, Clothing.Players[charId].converted)
    return Clothing.Players[charId]
end

--- Sets a player's appearance based on gender-specific data
---@param src number The server ID of the player
---@param data table Table containing separate appearance data for male and female characters
---@return table|nil
function Clothing.SetAppearanceExt(src, data)
    local tbl = Clothing.IsMale(src) and data.male or data.female
    Clothing.SetAppearance(src, tbl)
end

--- Reverts a player's appearance to their backup
---@param src number The server ID of the player
---@return table|nil
function Clothing.Revert(src)
    src = src and tonumber(src)
    assert(src, "src is nil")
    local currentClothing = Clothing.GetFullAppearanceData(src)
    if not currentClothing then return end
    local backup = currentClothing.backup
    if not backup then return end
    return Clothing.SetAppearance(src, backup)
end

--- Opens oxide-identity's clothing menu for a player
---@param src number The server ID of the player
function Clothing.OpenMenu(src)
    src = src and tonumber(src)
    assert(src, "src is nil")
    TriggerClientEvent('community_bridge:client:OpenClothingMenu', src)
end

--- Checks if a player's character model is male
---@param src number The server ID of the player
---@return boolean
function Clothing.IsMale(src)
    src = src and tonumber(src)
    if not src then return false end
    local data = Clothing.GetFullAppearanceData(src)
    if data and data.model then
        return data.model == 'mp_m_freemode_01'
    end
    local ped = GetPlayerPed(src)
    if not ped or not DoesEntityExist(ped) then return false end
    return GetEntityModel(ped) == `mp_m_freemode_01`
end

-- ============================================================================
-- Outfit Management
-- ============================================================================

function Clothing.SaveOutfit(src, name, data)
    local charId = Bridge.Framework.GetPlayerIdentifier(src)
    if not charId then return nil end
    local native = Clothing.ConvertFromDefault(data)
    return exports['oxide-identity']:SaveOutfit(tonumber(charId), name, native.components, native.props)
end

function Clothing.GetOutfits(src)
    local charId = Bridge.Framework.GetPlayerIdentifier(src)
    if not charId then return {} end
    local outfits = exports['oxide-identity']:GetOutfits(tonumber(charId))
    if not outfits then return {} end
    for i, outfit in ipairs(outfits) do
        local converted = Clothing.ConvertToDefault({ components = outfit.components, props = outfit.props })
        outfits[i].components = converted.components
        outfits[i].props = converted.props
    end
    return outfits
end

function Clothing.UpdateOutfit(src, outfitId, name, data)
    local native = Clothing.ConvertFromDefault(data)
    return exports['oxide-identity']:UpdateOutfit(tonumber(outfitId), name, native.components, native.props)
end

function Clothing.DeleteOutfit(src, outfitId)
    return exports['oxide-identity']:DeleteOutfit(tonumber(outfitId))
end

AddEventHandler('community_bridge:Server:OnPlayerLoaded', function(src)
    src = src and tonumber(src)
    assert(src, "src is nil")
    Clothing.GetFullAppearanceData(src)
end)

AddEventHandler('community_bridge:Server:OnPlayerUnload', function(src)
    src = src and tonumber(src)
    assert(src, "src is nil")
    local charId = Bridge.Framework.GetPlayerIdentifier(src)
    if charId then
        Clothing.Players[charId] = nil
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, playerId in ipairs(GetPlayers()) do
        local src = tonumber(playerId)
        if src then
            Clothing.GetFullAppearanceData(src)
        end
    end
end)

Callback.Register('community_bridge:cb:GetAppearance', function(source)
    return Clothing.GetAppearance(source)
end)
