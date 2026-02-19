---@diagnostic disable: duplicate-set-field

if GetResourceState('oxide-clothing') == 'missing' then return end

Clothing = Clothing or {}

---@return string
Clothing.GetResourceName = function()
    return 'oxide-clothing'
end

--- Opens oxide-clothing's character customization menu
function Clothing.OpenMenu()
    TriggerEvent('qb-clothing:client:openMenu')
end
