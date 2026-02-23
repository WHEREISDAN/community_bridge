---@diagnostic disable: duplicate-set-field
local resourceName = "oxide-progressbar"
local configValue = BridgeSharedConfig.ProgressBar or "auto"
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or
   (configValue ~= "auto" and configValue ~= resourceName) then
    return
end

ProgressBar = ProgressBar or {}

ProgressBar.GetResourceName = function()
    return resourceName
end

---This function opens a progress bar using oxide-progressbar.
---Converts from bridge/QB format to oxide-progressbar format.
---@param options table
---@param cb function|nil
---@param isQBInput boolean|nil
---@return boolean
function ProgressBar.Open(options, cb, isQBInput)
    if not options then return false end

    -- Convert from QB format if needed
    if isQBInput then
        local converted = {
            duration = options.duration,
            label = options.label,
            canCancel = options.allowCancel ~= nil and options.allowCancel or options.canCancel ~= nil and options.canCancel or true,
        }

        if options.controlDisables then
            converted.disableControls = {
                disableMovement = options.controlDisables.disableMovement,
                disableCombat = options.controlDisables.disableCombat,
                disableCarMovement = options.controlDisables.disableCarMovement,
                disableMouse = options.controlDisables.disableMouse,
            }
        end

        if options.animation then
            converted.animation = {
                dict = options.animation.animDict,
                clip = options.animation.anim,
                flags = options.animation.flags or 49,
            }
        end

        if options.prop then
            converted.prop = {
                model = options.prop.model,
                bone = options.prop.bone,
                offset = options.prop.coords,
                rotation = options.prop.rotation,
            }
        end

        options = converted
    end

    -- Build oxide-progressbar options
    local progressOptions = {
        duration = options.duration,
        label = options.label,
        canCancel = options.canCancel,
    }

    -- Animation: bridge uses anim.dict/clip/flag, oxide uses animation.dict/clip/flags
    if options.anim then
        progressOptions.animation = {
            dict = options.anim.dict,
            clip = options.anim.clip,
            flags = options.anim.flag or options.anim.flags or 49,
        }
    elseif options.animation then
        progressOptions.animation = {
            dict = options.animation.dict,
            clip = options.animation.clip or options.animation.anim,
            flags = options.animation.flags or options.animation.flag or 49,
        }
    end

    -- Prop mapping
    if options.prop then
        progressOptions.prop = {
            model = options.prop.model,
            bone = options.prop.bone,
            offset = options.prop.offset or options.prop.coords,
            rotation = options.prop.rotation,
        }
    end

    -- Disable controls: bridge uses disable.move/combat, oxide uses disableControls
    if options.disable then
        progressOptions.disableControls = {
            disableMovement = options.disable.move,
            disableCombat = options.disable.combat,
            disableCarMovement = options.disable.car,
            disableMouse = options.disable.mouse,
        }
    elseif options.disableControls then
        progressOptions.disableControls = options.disableControls
    end

    local success = exports['oxide-progressbar']:Progress(progressOptions)

    if cb then
        cb(success)
    end

    return success
end

return ProgressBar
