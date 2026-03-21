---@diagnostic disable: duplicate-set-field
Clothing = Clothing or {}
Clothing.LastAppearance = Clothing.LastAppearance or {}
Callback = Callback or Require("lib/callback/shared/callback.lua")

---This will get the name of the in use resource.
---@return string
Clothing.GetResourceName = function()
    return 'default'
end

---This will check if the player model if male/female
---@param src number
---@return boolean
function Clothing.IsMale(src)
    local ped = GetPlayerPed(src)
    if not ped or not DoesEntityExist(ped) then return false end
    return GetEntityModel(ped) == `mp_m_freemode_01`
end

---Get the skin data of a player
---@param src number
---@return table
function Clothing.GetAppearance(src)
    return Callback.Trigger('community_bridge:cb:GetAppearance', src)
end

---Apply skin data to a player
---@param src number
---@param data table
function Clothing.SetAppearance(src, data)
    local strSrc = tostring(src)
    Clothing.LastAppearance[strSrc] = Clothing.GetAppearance(src)
    TriggerClientEvent('community_bridge:client:SetAppearance', src, data)
end

--- Sets a player's appearance based on gender-specific data
---@param src number The server ID of the player
---@param data table Table containing separate appearance data for male and female characters
---@return table|nil Appearance updated player appearance data or nil if failed
function Clothing.SetAppearanceExt(src, data)
    local tbl = Clothing.IsMale(src) and data.male or data.female
    Clothing.SetAppearance(src, tbl)
end

---Restore the last saved appearance of a player
---@param src number
function Clothing.RestoreAppearance(src)
    TriggerClientEvent('community_bridge:client:RestoreAppearance', src)
end

---Save a named outfit for a player
---@param src number
---@param name string
---@param data table { components, props } in default format
---@return number|nil outfitId
function Clothing.SaveOutfit(src, name, data)
    print("[community_bridge] Clothing.SaveOutfit: No compatible clothing resource detected.")
    return nil
end

---Get all saved outfits for a player
---@param src number
---@return table[]
function Clothing.GetOutfits(src)
    print("[community_bridge] Clothing.GetOutfits: No compatible clothing resource detected.")
    return {}
end

---Update a saved outfit
---@param src number
---@param outfitId number|string
---@param name string
---@param data table { components, props } in default format
---@return boolean
function Clothing.UpdateOutfit(src, outfitId, name, data)
    print("[community_bridge] Clothing.UpdateOutfit: No compatible clothing resource detected.")
    return false
end

---Delete a saved outfit
---@param src number
---@param outfitId number|string
---@return boolean
function Clothing.DeleteOutfit(src, outfitId)
    print("[community_bridge] Clothing.DeleteOutfit: No compatible clothing resource detected.")
    return false
end

return Clothing