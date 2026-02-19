---@diagnostic disable: duplicate-set-field

if GetResourceState('oxide-clothing') == 'missing' then return end

Clothing = Clothing or {}
Clothing.ResourceName = 'oxide-clothing'

Components = {}
-- oxide-clothing uses numeric component IDs (0-11) with {drawable, texture} values
Components.Map = {
    [0] = 0, [1] = 1, [2] = 2, [3] = 3, [4] = 4, [5] = 5,
    [6] = 6, [7] = 7, [8] = 8, [9] = 9, [10] = 10, [11] = 11
}

Props = {}
Props.Map = {
    [0] = 0, [1] = 1, [2] = 2, [6] = 6, [7] = 7
}

--- Convert oxide-clothing components {[0]={drawable,texture},...} to default format {[0]={component_id,drawable,texture},...}
function Components.ConvertToDefault(oxideComponents)
    local result = {}
    for k, v in pairs(oxideComponents or {}) do
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

--- Convert default format back to oxide-clothing components
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

--- Convert oxide-clothing props {[0]={drawable,texture},...} to default format sorted array
function Props.ConvertToDefault(oxideProps)
    local result = {}
    for k, v in pairs(oxideProps or {}) do
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

--- Convert default format props back to oxide-clothing format
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

--- Convert full oxide-clothing data to default format
function Clothing.ConvertToDefault(oxideData)
    return {
        components = Components.ConvertToDefault(oxideData.components),
        props = Props.ConvertToDefault(oxideData.props)
    }
end

--- Convert default format back to oxide-clothing format
function Clothing.ConvertFromDefault(defaultData)
    return {
        components = Components.ConvertFromDefault(defaultData.components),
        props = Props.ConvertFromDefault(defaultData.props)
    }
end
