local INT32_FORMAT <const> = '<i4'
local INT32_SIZE <const> = 4
local createBlob <const> = rawget(string, 'blob') or function(length)
    return string.rep('\0', length)
end

---@class EventDataBuffer
---@field blob string
---@field length integer
local EventDataBuffer = {}
EventDataBuffer.__index = EventDataBuffer

local function isInt32InBounds(buffer, offset)
    return type(offset) == 'number'
        and offset >= 0
        and offset + INT32_SIZE <= buffer.length
end

---@return string
function EventDataBuffer:Buffer()
    return self.blob
end

---@param offset number Zero-based byte offset.
---@return integer|nil
function EventDataBuffer:GetInt32(offset)
    if not isInt32InBounds(self, offset) then return nil end

    local value = string.unpack(INT32_FORMAT, self.blob, offset + 1)
    return value
end

---@param length integer Buffer size in bytes.
---@return EventDataBuffer
function CreateEventDataBuffer(length)
    assert(type(length) == 'number' and length >= 0 and length % 1 == 0, 'buffer length must be a non-negative integer')

    return setmetatable({
        blob = createBlob(length),
        length = length,
    }, EventDataBuffer)
end
