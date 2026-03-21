---@diagnostic disable: duplicate-set-field
local resourceName = "oxide-vehicles"
if GetResourceState(resourceName) == 'missing' then return end

VehicleOwnership = VehicleOwnership or {}

---Transfers vehicle ownership by plate to a new owner (char_id).
---@param plate string The vehicle's license plate
---@param newOwnerIdentifier number The new owner's character ID
---@return boolean success
VehicleOwnership.TransferOwnership = function(plate, newOwnerIdentifier)
    assert(type(plate) == "string", "Expected 'plate' to be a string")
    assert(newOwnerIdentifier ~= nil, "Expected 'newOwnerIdentifier' to not be nil")

    return exports[resourceName]:TransferOwnership(plate, tonumber(newOwnerIdentifier))
end

VehicleOwnership.GetResourceName = function()
    return resourceName
end

return VehicleOwnership
