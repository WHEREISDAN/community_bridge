---@diagnostic disable: duplicate-set-field
local resourceName = "qbx_vehicles"
if GetResourceState(resourceName) == 'missing' then return end

VehicleOwnership = VehicleOwnership or {}

---Transfers vehicle ownership by plate to a new owner (citizenid).
---Uses qbx_vehicles exports: GetVehicleIdByPlate + SetPlayerVehicleOwner.
---@param plate string The vehicle's license plate
---@param newOwnerIdentifier string The new owner's citizenid
---@return boolean success
VehicleOwnership.TransferOwnership = function(plate, newOwnerIdentifier)
    assert(type(plate) == "string", "Expected 'plate' to be a string")
    assert(type(newOwnerIdentifier) == "string", "Expected 'newOwnerIdentifier' to be a string (citizenid)")

    local vehicleId = exports[resourceName]:GetVehicleIdByPlate(plate)
    if not vehicleId then
        return false
    end

    local success = exports[resourceName]:SetPlayerVehicleOwner(vehicleId, newOwnerIdentifier)
    return success == true
end

VehicleOwnership.GetResourceName = function()
    return resourceName
end

return VehicleOwnership
