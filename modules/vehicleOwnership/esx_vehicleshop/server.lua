---@diagnostic disable: duplicate-set-field
local resourceName = "es_extended"
if GetResourceState(resourceName) == 'missing' then return end

VehicleOwnership = VehicleOwnership or {}

---Transfers vehicle ownership by plate to a new owner (ESX identifier).
---Uses direct SQL since ESX's class method requires the vehicle to be spawned.
---@param plate string The vehicle's license plate
---@param newOwnerIdentifier string The new owner's ESX identifier
---@return boolean success
VehicleOwnership.TransferOwnership = function(plate, newOwnerIdentifier)
    assert(type(plate) == "string", "Expected 'plate' to be a string")
    assert(type(newOwnerIdentifier) == "string", "Expected 'newOwnerIdentifier' to be a string (identifier)")

    local affectedRows = MySQL.update.await(
        'UPDATE owned_vehicles SET owner = ? WHERE plate = ?',
        { newOwnerIdentifier, plate }
    )

    return affectedRows and affectedRows > 0
end

VehicleOwnership.GetResourceName = function()
    return resourceName
end

return VehicleOwnership
