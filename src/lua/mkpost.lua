local cmark = require("cmark")
local s = require("serpent")

local meta = dofile(arg[1] .. "/meta.lua")
if not meta.name then
    meta.name = string.gsub(string.gsub(arg[1],"^.*/",""),"%d%d%d%d[%d-/]*_?","")
end
if meta.date then
    local h = io.popen("git rev-parse --since='"..meta.date.."'")
    local timestamp = tonumber(string.sub(h:read("*a"),11))
    if timestamp and timestamp > 0 then
        meta.year = meta.year or os.date("%Y",timestamp)
        meta.month = meta.month or os.date("%m",timestamp)
        meta.day = meta.day or os.date("%d",timestamp)
        meta.timestamp = timestamp
    end
end
if meta.section then
    if type(meta.section) == "table" then
        meta.sections = meta.section
    else
        meta.sections = { meta.section }
    end
    meta.section = nil
end

local f = assert(io.open(arg[1] .. "/index.md", "r"))
meta.body = cmark.to_html(f:read("*all"))
f:close()

print(s.dump(meta))
