---@diagnostic disable: duplicate-set-field
local resourceName = "oxide-phone"
local configValue = BridgeSharedConfig.Phone
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or
   (configValue ~= "auto" and configValue ~= resourceName) then
    return
end

Phone = Phone or {}

---This will get the name of the Phone system being used.
---@return string
Phone.GetPhoneName = function()
    return resourceName
end

Phone.GetResourceName = function()
    return resourceName
end

---This will get the phone number of the passed source.
---@param src number
---@return string|boolean
Phone.GetPlayerPhone = function(src)
    local ok, result = pcall(exports['oxide-phone'].GetPhoneNumber, exports['oxide-phone'], src)
    if ok and result then return result end
    return false
end

---This will send an email via oxide-phone.
---@param src number
---@param email string
---@param title string
---@param message string
---@return boolean
Phone.SendEmail = function(src, email, title, message)
    local ok, result = pcall(exports['oxide-phone'].SendServiceEmail, exports['oxide-phone'],
        'Community Bridge', 'noreply@bridge.com', email, title, message)
    if ok then return result ~= nil end
    return false
end

---This will send a service message (SMS) to a phone number.
---@param serviceName string
---@param phoneNumber string
---@param content string
---@return boolean
Phone.SendServiceMessage = function(serviceName, phoneNumber, content)
    local ok, result = pcall(exports['oxide-phone'].SendServiceMessage, exports['oxide-phone'],
        serviceName, phoneNumber, content)
    if ok then return result ~= nil end
    return false
end

return Phone
