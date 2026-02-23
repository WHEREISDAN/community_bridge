local resourceName = "oxide-menu"
local configValue = BridgeClientConfig.MenuSystem
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end
Menus = Menus or {}

---Converts bridge options to oxide-menu items.
---@param options table The bridge menu options.
---@return table The oxide-menu items.
local function ConvertOptions(options)
    if not options then return {} end
    local items = {}
    for i, v in ipairs(options) do
        items[i] = {
            id = v.id,
            title = v.title,
            description = v.description,
            icon = v.icon,
            iconColor = v.iconColor,
            action = v.onSelect,
            event = v.event,
            serverEvent = v.serverEvent,
            args = v.args,
            disabled = v.disabled,
            metadata = v.metadata,
            keepOpen = v.keepOpen,
        }
    end
    return items
end

---Converts a QB menu to oxide-menu format.
---@param id string The menu ID.
---@param menu table The QB menu data.
---@return table The oxide-menu data.
local function QBToOxideMenu(id, menu)
    local oxideMenu = {
        id = id,
        title = "",
        items = {},
    }
    for _, v in pairs(menu) do
        if v.isMenuHeader then
            if oxideMenu.title == "" then
                oxideMenu.title = v.header
            end
        else
            oxideMenu.items[#oxideMenu.items + 1] = {
                title = v.header,
                description = v.txt,
                icon = v.icon,
                args = v.params and v.params.args,
                action = v.action or function(args)
                    local params = v.params
                    if not params then return end
                    local event = params.event
                    local isServer = params.isServer
                    if not event then return end
                    if isServer then
                        return TriggerServerEvent(event, args)
                    end
                    return TriggerEvent(event, args)
                end,
            }
        end
    end
    return oxideMenu
end

function OpenMenu(id, data, useQBinput)
    if useQBinput then
        data = QBToOxideMenu(id, data)
    else
        data = {
            id = data.id or id,
            title = data.title or '',
            subtitle = data.subtitle,
            items = ConvertOptions(data.options),
            onClose = data.onClose,
        }
    end
    exports['oxide-menu']:Open(data)
    return data
end

function GetMenuResourceName()
    return resourceName
end
