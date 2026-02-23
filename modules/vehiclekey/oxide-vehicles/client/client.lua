---@diagnostic disable: duplicate-set-field
local resourceName = "oxide-vehicles"
if GetResourceState(resourceName) == 'missing' then return end

VehicleKey = VehicleKey or {}

---Gives the player (self) the keys of the specified vehicle.
---@param vehicle number The vehicle entity handle.
---@param plate? string The plate of the vehicle.
---@return nil
VehicleKey.GiveKeys = function(vehicle, plate)
    assert(vehicle, "vehicle is nil")
    assert(DoesEntityExist(vehicle), "vehicle does not exist")

    if not plate then
        plate = GetVehicleNumberPlateText(vehicle)
    end

    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    TriggerServerEvent('oxide:vehicles:bridgeGiveKeys', netId, plate, model)
end

---Removes the keys of the specified vehicle from the player (self).
---@param vehicle number The vehicle entity handle.
---@param plate? string The plate of the vehicle.
---@return nil
VehicleKey.RemoveKeys = function(vehicle, plate)
    assert(vehicle, "vehicle is nil")
    assert(DoesEntityExist(vehicle), "vehicle does not exist")

    if not plate then
        plate = GetVehicleNumberPlateText(vehicle)
    end

    TriggerServerEvent('oxide:vehicles:bridgeRemoveKeys', plate)
end

VehicleKey.GetResourceName = function()
    return resourceName
end

return VehicleKey
