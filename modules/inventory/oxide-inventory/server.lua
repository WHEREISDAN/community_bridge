---@diagnostic disable: duplicate-set-field
if GetResourceState('oxide-inventory') == 'missing' then return end

local Oxide = exports['oxide-core']:Core()
local InventoryAPI

Inventory = Inventory or {}
Inventory.Stashes = Inventory.Stashes or {}

local function GetInv()
    if not InventoryAPI then
        InventoryAPI = exports['oxide-inventory']:Inventory()
    end
    return InventoryAPI
end

local function GetCharId(src)
    local player = Oxide.Functions.GetPlayer(src)
    if not player then return nil end
    local character = player.GetCharacter()
    if not character then return nil end
    return character.charId
end

---@description This will get the name of the in use resource.
---@return string
Inventory.GetResourceName = function()
    return "oxide-inventory"
end

---@description This will add an item, and return true or false based on success
---@param src number
---@param item string
---@param count number
---@param slot number (optional, unused by oxide-inventory)
---@param metadata table (optional)
---@return boolean
Inventory.AddItem = function(src, item, count, slot, metadata)
    local charId = GetCharId(src)
    if not charId then return false end
    local success, err = GetInv().AddItem(charId, item, count, metadata)
    if not success then return false end
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "add", item = item, count = count, slot = slot, metadata = metadata})
    return true
end

---@description This will remove an item, and return true or false based on success
---@param src number
---@param item string
---@param count number
---@param slot number (optional, unused)
---@param metadata table (optional, unused)
---@return boolean
Inventory.RemoveItem = function(src, item, count, slot, metadata)
    item = type(item) == "table" and item.name or item
    local charId = GetCharId(src)
    if not charId then return false end
    local success, err
    if slot and slot > 0 then
        local inv = GetInv()
        -- Find the containerId for this slot
        local items = inv.GetAllItems(charId)
        local containerId
        for _, v in ipairs(items or {}) do
            if v.slot == slot and v.name == item then
                containerId = v.containerId
                break
            end
        end
        if containerId then
            local removed = inv.RemoveFromSlot(charId, containerId, slot, count)
            success = removed ~= nil
        else
            success, err = inv.RemoveItem(charId, item, count)
        end
    else
        success, err = GetInv().RemoveItem(charId, item, count)
    end
    if not success then return false end
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "remove", item = item, count = count, slot = slot, metadata = metadata})
    return true
end

---@description This will return a table with the item info, {name, label, stack, weight, description, image}
---@param item string
---@return table
Inventory.GetItemInfo = function(item)
    local itemDef = Oxide.GetItem(item)
    if not itemDef then return {} end
    return {
        name = item,
        label = itemDef.label or item,
        stack = itemDef.stackable and tostring(itemDef.maxStack) or "false",
        weight = itemDef.weight or 0,
        description = itemDef.description or "none",
        image = string.format("nui://oxide-inventory/web/public/items/%s.png", item),
    }
end

---@description This will return the entire items table from the inventory.
---@return table
Inventory.Items = function()
    return Oxide.Items or {}
end

---@description This will return the count of the item in the players inventory, if not found will return 0.
---@param src number
---@param item string
---@param metadata table (optional, unused)
---@return number
Inventory.GetItemCount = function(src, item, metadata)
    local charId = GetCharId(src)
    if not charId then return 0 end
    return GetInv().CountItem(charId, item)
end

---@description This will return the players inventory.
---@param src number
---@return table
Inventory.GetPlayerInventory = function(src)
    local charId = GetCharId(src)
    if not charId then return {} end
    return GetInv().GetAllItems(charId)
end

---@description Returns the specified slot data as a table.
---@param src number
---@param slot number
---@return table
Inventory.GetItemBySlot = function(src, slot)
    local charId = GetCharId(src)
    if not charId then return {} end
    local inv = GetInv().GetInventory(charId)
    if not inv then return {} end
    for _, container in ipairs(inv) do
        for _, item in ipairs(container.items or {}) do
            if item.slot == slot then
                return {
                    name = item.name,
                    label = item.label,
                    count = item.amount,
                    slot = item.slot,
                    weight = item.weight,
                    metadata = item.metadata or {},
                }
            end
        end
    end
    return {}
end

---@description This will set the metadata of an item in the inventory.
---@param src number
---@param item string
---@param slot number
---@param metadata table
---@return nil
Inventory.SetMetadata = function(src, item, slot, metadata)
    local charId = GetCharId(src)
    if not charId then return end
    if type(metadata) == 'table' then
        for key, value in pairs(metadata) do
            GetInv().SetItemMetadata(charId, nil, slot, key, value)
        end
    end
end

---@description This will register a stash
---@param id number|string
---@param label string
---@param slots number
---@param weight number
---@param owner string (optional)
---@param groups table (optional, unused by oxide-inventory)
---@param coords table (optional)
---@return boolean
---@return string|number
Inventory.RegisterStash = function(id, label, slots, weight, owner, groups, coords)
    id = tostring(id)
    if Inventory.Stashes[id] then return true, id end
    Inventory.Stashes[id] = {id = id, label = label, slots = slots, weight = weight, owner = owner, groups = groups, coords = coords}
    GetInv().RegisterStash(id, label, slots, weight, owner)
    return true, id
end

---@description This will open the specified stash for the src passed.
---@param src number
---@param _type string "stash", "trunk", "glovebox"
---@param id string
---@return nil
Inventory.OpenStash = function(src, _type, id)
    _type = _type or "stash"
    TriggerClientEvent('oxide:inventory:openStash', src, tostring(id))
end

---@description This will add items to a stash, and return true or false based on success
---@param id string
---@param items table {item, count, metadata}
---@return boolean
Inventory.AddStashItems = function(id, items)
    if type(items) ~= "table" then return false end
    local inv = GetInv()
    local success = false
    for _, v in pairs(items) do
        local ok = inv.AddStashItem(tostring(id), v.item, v.count or v.amount or 1, v.metadata or v.info)
        if ok then success = true end
    end
    return success
end

---@description This will clear the specified stash.
---@param id string
---@param _type string (optional, unused)
---@return boolean
Inventory.ClearStash = function(id, _type)
    id = tostring(id)
    -- Remove all items by getting and removing each
    local inv = GetInv()
    local items = inv.GetStashItems(id)
    for _, item in ipairs(items) do
        inv.RemoveStashItem(id, item.name, item.amount)
    end
    if Inventory.Stashes[id] then Inventory.Stashes[id] = nil end
    return true
end

---@description This will get all items in a stash
---@param id string
---@return table
Inventory.GetStashItems = function(id)
    return GetInv().GetStashItems(tostring(id))
end

---@description This will remove an item from a stash
---@param id string
---@param item string
---@param count number
---@return boolean
Inventory.RemoveStashItem = function(id, item, count)
    return GetInv().RemoveStashItem(tostring(id), item, count)
end

---@description This will return a boolean if the player has the item.
---@param src number
---@param item string
---@param requiredCount number (optional)
---@return boolean
Inventory.HasItem = function(src, item, requiredCount)
    local charId = GetCharId(src)
    if not charId then return false end
    return GetInv().HasItem(charId, item, requiredCount or 1)
end

---@description This is to get if there is available space in the inventory, will return boolean.
---@param src number
---@param item string
---@param count number
---@return boolean
Inventory.CanCarryItem = function(src, item, count)
    local charId = GetCharId(src)
    if not charId then return false end
    return GetInv().CanAddItem(charId, item, count or 1)
end

---@description This will update the plate to the vehicle inside the inventory.
---@param oldplate string
---@param newplate string
---@return boolean
Inventory.UpdatePlate = function(oldplate, newplate)
    return false, print("oxide-inventory does not have vehicle trunk management.")
end

---@description This will add items to a trunk, and return true or false based on success
---@param identifier string
---@param items table
---@return boolean
Inventory.AddTrunkItems = function(identifier, items)
    local id = "trunk" .. tostring(identifier)
    if type(items) ~= "table" then return false end
    Inventory.RegisterStash(id, identifier, 20, 100.0)
    Wait(100)
    return Inventory.AddStashItems(id, items)
end

---@description This will get the image path for an item.
---@param item string
---@return string
Inventory.GetImagePath = function(item)
    item = Inventory.StripPNG(item)
    local file = LoadResourceFile("oxide-inventory", string.format("web/public/items/%s.png", item))
    if file then
        return string.format("nui://oxide-inventory/web/public/items/%s.png", item)
    end
    return "https://avatars.githubusercontent.com/u/47620135"
end

---@description This will open the specified shop for the src passed.
---@param src number
---@param shopTitle string
Inventory.OpenShop = function(src, shopTitle)
    return Bridge.Shops.OpenShop(src, shopTitle)
end

---@description This will register a shop, if it already exists it will return true.
---@param shopTitle string
---@param shopInventory table
---@param shopCoords table
---@param shopGroups table
Inventory.RegisterShop = function(shopTitle, shopInventory, shopCoords, shopGroups)
    return Bridge.Shops.CreateShop(shopTitle, shopInventory, shopCoords, shopGroups)
end

---@description Opens another player's inventory for inspection/interaction
---@param src number
---@param targetSrc number
---@return boolean
Inventory.OpenPlayerInventory = function(src, targetSrc)
    return false, print("oxide-inventory does not support opening another player's inventory directly.")
end

return Inventory
