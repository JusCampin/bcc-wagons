-- bcc-farming resource debug system (resource-scoped global)
-- DO NOT MAKE CHANGES TO THIS FILE
if not BCCWagonsDebug then
    ---@class BCCWagonsDebugLib
    ---@field Info fun(message: string)
    ---@field Error fun(message: string)
    ---@field Warning fun(message: string)
    ---@field Success fun(message: string)
    ---@field DevModeActive boolean
    BCCWagonsDebug = {}

    BCCWagonsDebug.DevModeActive = Config and Config.devMode and Config.devMode.active or false

    -- No-op function
    local function noop() end

    -- Function to create loggers
    local function createLogger(prefix, color)
        if BCCWagonsDebug.DevModeActive then
            return function(message)
                print(('^%d[%s] ^3%s^0'):format(color, prefix, message))
            end
        else
            return noop
        end
    end

    -- Create loggers with appropriate colors
    BCCWagonsDebug.Info = createLogger("INFO", 5)    -- Purple
    BCCWagonsDebug.Error = createLogger("ERROR", 1)  -- Red
    BCCWagonsDebug.Warning = createLogger("WARNING", 3) -- Yellow
    BCCWagonsDebug.Success = createLogger("SUCCESS", 2) -- Green

    -- Make it globally available
    _G.BCCWagonsDebug = BCCWagonsDebug
end
