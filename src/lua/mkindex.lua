local s = require("serpent")

local x = {posts = {}, drafts = {}, rchrono = {}, years = {}, months = {}}
local indices = {"tags", "sections", "authors", "year", "month"}
local indexmeta = {__index = function(t,k)
    t[k]={}
    --setmetatable(t[k],indexmeta)
    return t[k]
end}
for i,k in ipairs(indices) do
    x[k] = setmetatable({}, indexmeta)
end

for path in io.lines() do
    local post = dofile(path)
    x.drafts[post.name] = post
    if post.published then
        x.posts[post.name] = post
        table.insert(x.rchrono, post)
        for i,k in ipairs(indices) do
            if post[k] then
                if type(post[k]) == "table" then
                    if k ~= "tags" and #post[k] ~= 1 then
                        table.insert(x[k][table.concat(post[k],",")], post)
                    end
                    for j,a in ipairs(post[k]) do
                        table.insert(x[k][a], post)
                    end
                elseif k ~= "month" then
                    table.insert(x[k][post[k]],post)
                end
            end
        end
    end
end

local function rchrono(a,b)
    if b.timestamp then
        if a.timestamp then
            return a.timestamp > b.timestamp
        else return false end
    else return true end
end

table.sort(x.rchrono,rchrono)
for i,k in ipairs(indices) do
    for j,l in ipairs(x[k]) do
        table.sort(l,rchrono)
    end
end

function index_ym(s,z)
    setmetatable(s.month,indexmeta)
    setmetatable(s.months,indexmeta)
    local y,m = 9999,0
    for i,p in ipairs(z) do
        if (not (p.timestamp and p.timestamp > 0)) then 
            io.stderr:write("Warning: "..p.name.." has no timestamp\n")
        else
            if(tonumber(p.year) < tonumber(y)) then
                y,m = p.year,p.month
                table.insert(s.years,y)
                table.insert(s.months[y],m)
            elseif (p.month < m) then
                table.insert(s.months[y],m)
            end
            table.insert(s.month[y..m],p)
        end
    end
    setmetatable(s.month,{})
    setmetatable(s.months,{})
end
index_ym(x,x.rchrono)

x.section = {}
for sec,z in pairs(x.sections) do
    local s = {years = {}, months = {}, month = {}}
    index_ym(s,z)
    x.section[sec] = s
end

for i,j in ipairs(indices) do
    setmetatable(x[j],{})
end

print(s.dump(x))
