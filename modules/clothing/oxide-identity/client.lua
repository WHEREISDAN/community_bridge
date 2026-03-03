---@diagnostic disable: duplicate-set-field

if GetResourceState('oxide-identity') == 'missing' then return end

Clothing = Clothing or {}

---@return string
Clothing.GetResourceName = function()
    return 'oxide-identity'
end

--- Opens oxide-identity's clothing menu
function Clothing.OpenMenu()
    exports['oxide-identity']:OpenClothing()
end

RegisterNetEvent('community_bridge:client:OpenClothingMenu', function()
    if source ~= 65535 then return end
    Clothing.OpenMenu()
end)
