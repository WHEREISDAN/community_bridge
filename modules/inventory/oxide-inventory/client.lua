---@diagnostic disable: duplicate-set-field
if GetResourceState('oxide-inventory') == 'missing' then return end

local Oxide = exports['oxide-core']:Core()

Inventory = Inventory or {}

---@description This will get the name of the in use resource.
---@return string
Inventory.GetResourceName = function()
    return "oxide-inventory"
end

---@description Return the item info, {name, label, stack, weight, description, image}
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

---@description Will return boolean if the player has the item.
---@param item string
---@param requiredCount number (optional)
---@return boolean
Inventory.HasItem = function(item, requiredCount)
    requiredCount = requiredCount or 1
    return Inventory.GetItemCount(item) >= requiredCount
end

---@description This will return the count of the item in the players inventory, if not found will return 0.
---@param item string
---@return number
Inventory.GetItemCount = function(item)
    local inventory = LocalPlayer.state['oxide:inventory']
    if not inventory or not inventory.containers then return 0 end
    local count = 0
    for _, container in ipairs(inventory.containers) do
        for _, slot in ipairs(container.items or {}) do
            if slot and slot.name == item then
                count = count + (slot.amount or 1)
            end
        end
    end
    return count
end

---@description This will get the image path for this item.
---@param item string
---@return string
Inventory.GetImagePath = function(item)
    item = Inventory.StripPNG(item)
    return string.format("nui://oxide-inventory/web/public/items/%s.png", item)
end

---@description This will return the players inventory.
---@return table
Inventory.GetPlayerInventory = function()
    local inventory = LocalPlayer.state['oxide:inventory']
    if not inventory or not inventory.containers then return {} end
    local items = {}
    for _, container in ipairs(inventory.containers) do
        for _, item in ipairs(container.items or {}) do
            if item then
                items[#items + 1] = {
                    name = item.name,
                    label = item.label,
                    count = item.amount,
                    slot = item.slot,
                    metadata = item.metadata or {},
                }
            end
        end
    end
    return items
end

return Inventory
