---@diagnostic disable: duplicate-set-field
local resourceName = "oxide-notify"
local configValue = BridgeSharedConfig.Notify
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or
   (configValue ~= "auto" and configValue ~= resourceName) then
    return
end

Notify = Notify or {}

Notify.GetResourceName = function()
    return resourceName
end

---DEPRECATED: PLEASE SWITCH TO Notify.SendNotification
---@param message string
---@param _type string
---@param time number
---@return nil
Notify.SendNotify = function(message, _type, time)
    exports['oxide-notify']:Notify(message, _type)
end

---This will send a notify message of the type and time passed
---@param title string
---@param message string
---@param _type string
---@param time number
---@param props table|nil
---@return nil
Notify.SendNotification = function(title, message, _type, time, props)
    exports['oxide-notify']:Notify({
        title = title,
        message = message or title,
        type = _type,
        duration = time,
    })
end

return Notify
