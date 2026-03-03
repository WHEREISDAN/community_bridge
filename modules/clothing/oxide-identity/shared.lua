---@diagnostic disable: duplicate-set-field

if GetResourceState('oxide-identity') == 'missing' then return end

Clothing = Clothing or {}
Clothing.ResourceName = 'oxide-identity'

Components = {}
-- oxide-identity uses numeric component IDs (0-11) with {drawable, texture} values
Components.Map = {
    [0] = 0, [1] = 1, [2] = 2, [3] = 3, [4] = 4, [5] = 5,
    [6] = 6, [7] = 7, [8] = 8, [9] = 9, [10] = 10, [11] = 11
}

Props = {}
Props.Map = {
    [0] = 0, [1] = 1, [2] = 2, [6] = 6, [7] = 7
}

--- Convert oxide-identity components {[0]={drawable,texture},...} to default format {[0]={component_id,drawable,texture},...}
function Components.ConvertToDefault(nativeComponents)
    local result = {}
    for k, v in pairs(nativeComponents or {}) do
        local id = tonumber(k)
        if id and v.drawable then
            result[id] = {
                component_id = id,
                drawable = v.drawable,
                texture = v.texture
            }
        end
    end
    return result
end

--- Convert default format back to oxide-identity components
function Components.ConvertFromDefault(defaultComponents)
    local result = {}
    for _, v in pairs(defaultComponents or {}) do
        if v.component_id then
            result[v.component_id] = {
                drawable = v.drawable,
                texture = v.texture
            }
        end
    end
    return result
end

--- Convert oxide-identity props {[0]={drawable,texture},...} to default format sorted array
function Props.ConvertToDefault(nativeProps)
    local result = {}
    for k, v in pairs(nativeProps or {}) do
        local id = tonumber(k)
        if id and v.drawable then
            table.insert(result, {
                prop_id = id,
                drawable = v.drawable,
                texture = v.texture
            })
        end
    end
    table.sort(result, function(a, b) return a.prop_id < b.prop_id end)
    return result
end

--- Convert default format props back to oxide-identity format
function Props.ConvertFromDefault(defaultProps)
    local result = {}
    for _, v in pairs(defaultProps or {}) do
        if v.prop_id then
            result[v.prop_id] = {
                drawable = v.drawable,
                texture = v.texture
            }
        end
    end
    return result
end

--- Convert full oxide-identity data to default format
function Clothing.ConvertToDefault(nativeData)
    return {
        components = Components.ConvertToDefault(nativeData.components),
        props = Props.ConvertToDefault(nativeData.props)
    }
end

--- Convert default format back to oxide-identity format
function Clothing.ConvertFromDefault(defaultData)
    return {
        components = Components.ConvertFromDefault(defaultData.components),
        props = Props.ConvertFromDefault(defaultData.props)
    }
end
