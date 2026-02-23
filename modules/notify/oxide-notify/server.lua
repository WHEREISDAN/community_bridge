---@diagnostic disable: duplicate-set-field
local resourceName = "oxide-notify"
local configValue = BridgeSharedConfig.Notify
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or
   (configValue ~= "auto" and configValue ~= resourceName) then return end

Notify = Notify or {}

Notify.Confirm = function(src, options, callback)
    exports['oxide-notify']:Confirm(src, options, callback)
end

return Notify
