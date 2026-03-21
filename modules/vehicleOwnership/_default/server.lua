---@diagnostic disable: duplicate-set-field
VehicleOwnership = VehicleOwnership or {}

---Transfers vehicle ownership by plate to a new owner.
---@param plate string The vehicle's license plate
---@param newOwnerIdentifier string|number The new owner's framework identifier
---@return boolean success
VehicleOwnership.TransferOwnership = function(plate, newOwnerIdentifier)
    print("[community_bridge] VehicleOwnership.TransferOwnership: No compatible vehicle resource detected.")
    return false
end

VehicleOwnership.GetResourceName = function()
    return "default"
end

return VehicleOwnership
