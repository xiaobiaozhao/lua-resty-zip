-- mainly from http://luajit.org/ext_ffi_tutorial.html

local ffi = require "ffi"
local ffi_new = ffi.new
local ffi_str = ffi.string
local zip = ffi.C

local _M = {_VERSION = "0.02"}

ffi.cdef [[
    unsigned long compressBound(unsigned long sourceLen);
    int compress2(uint8_t *dest, unsigned long *destLen,
        const uint8_t *source, unsigned long sourceLen, int level);
    int uncompress(uint8_t *dest, unsigned long *destLen,
        const uint8_t *source, unsigned long sourceLen);
]]

if ffi.os == "OSX" then
    zip = ffi.load("z")
end

-- level: 0 - 9
function _M.compress(txt, level)
    local n = zip.compressBound(#txt)
    local buf = ffi_new("uint8_t[?]", n)

    local buflen = ffi_new("unsigned long[1]", n)
    local res = zip.compress2(buf, buflen, txt, #txt, level or 1)

    if res == 0 then
        return ffi_str(buf, buflen[0])
    end
end

function _M.uncompress(comp, n)
    local buf = ffi_new("uint8_t[?]", n)

    local buflen = ffi_new("unsigned long[1]", n)
    local res = zip.uncompress(buf, buflen, comp, #comp)

    if res == 0 then
        return ffi_str(buf, buflen[0])
    end
end

return _M
