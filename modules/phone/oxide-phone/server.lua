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
---@param email string The sender/service name
---@param title string
---@param message string
---@return boolean
Phone.SendEmail = function(src, email, title, message)
    local ok, playerEmail = pcall(exports['oxide-phone'].GetEmailAddress, exports['oxide-phone'], src)
    if not ok or not playerEmail then return false end
    local ok2, result = pcall(exports['oxide-phone'].SendServiceEmail, exports['oxide-phone'],
        email, email .. '@service.com', playerEmail, title, message)
    if ok2 then return result ~= nil end
    return false
end

return Phone
