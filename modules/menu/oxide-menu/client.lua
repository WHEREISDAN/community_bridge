local resourceName = "oxide-menu"
local configValue = BridgeClientConfig.MenuSystem
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end
Menus = Menus or {}

-- Store callbacks locally since functions can't cross the export boundary to oxide-menu
local menuCallbacks = {}
local BRIDGE_SELECT_EVENT = 'community_bridge:oxide-menu:select'

---Converts bridge options to oxide-menu items.
---@param menuId string The menu ID for callback storage.
---@param options table The bridge menu options.
---@return table The oxide-menu items.
local function ConvertOptions(menuId, options)
    if not options then return {} end
    menuCallbacks[menuId] = {}
    local items = {}
    for i, v in ipairs(options) do
        local itemId = ('%s_%d'):format(menuId, i)

        if v.onSelect then
            menuCallbacks[menuId][itemId] = v.onSelect
        end

        items[i] = {
            id = itemId,
            title = v.title,
            description = v.description,
            icon = v.icon,
            iconColor = v.iconColor,
            event = v.onSelect and BRIDGE_SELECT_EVENT or v.event,
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
    menuCallbacks[id] = {}
    local oxideMenu = {
        id = id,
        title = "",
        items = {},
    }
    local idx = 0
    for _, v in pairs(menu) do
        if v.isMenuHeader then
            if oxideMenu.title == "" then
                oxideMenu.title = v.header
            end
        else
            idx = idx + 1
            local itemId = ('%s_%d'):format(id, idx)
            local cb = v.action or function(args)
                local params = v.params
                if not params then return end
                local event = params.event
                local isServer = params.isServer
                if not event then return end
                if isServer then
                    return TriggerServerEvent(event, args)
                end
                return TriggerEvent(event, args)
            end

            menuCallbacks[id][itemId] = cb

            oxideMenu.items[#oxideMenu.items + 1] = {
                id = itemId,
                title = v.header,
                description = v.txt,
                icon = v.icon,
                args = v.params and v.params.args,
                event = BRIDGE_SELECT_EVENT,
            }
        end
    end
    return oxideMenu
end

-- Handle item selection via event (since functions can't cross export boundaries)
AddEventHandler(BRIDGE_SELECT_EVENT, function(args, item)
    if not item or not item.id then return end
    for _, callbacks in pairs(menuCallbacks) do
        local cb = callbacks[item.id]
        if cb then
            cb(args)
            return
        end
    end
end)

function OpenMenu(id, data, useQBinput)
    local menuId = data.id or id
    if useQBinput then
        data = QBToOxideMenu(menuId, data)
    else
        data = {
            id = menuId,
            title = data.title or '',
            subtitle = data.subtitle,
            items = ConvertOptions(menuId, data.options),
            onClose = data.onClose,
        }
    end
    exports['oxide-menu']:Open(data)
    return data
end

function GetMenuResourceName()
    return resourceName
end
