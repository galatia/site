local M = {}
cx = require "content"
local t = require "templates"
site = {}

local function current_domains()
    local host = ngx.var.host
    local m = ngx.re.match(host,[=[((\w+)[.])?(localhost|([^.]*)[.](org|net|com|io|is))]=])
    return (m and m[2]), (m and m[3])
end

local function current_domain()
    local sd, d = current_domains()
    return d
end
site.current_domain = current_domain

local function current_subdomain()
    local sd, d = current_domains()
    return sd
end
site.current_subdomain = current_subdomain

local function current_port()
  return ngx.var.http_x_orig_port or ngx.var.server_port
end
site.current_port = current_port

local function current_domain_port()
    local domain = current_domain()
    local port = current_port()
    if port ~= 80 then domain = domain .. ":" .. port end
    return domain
end
site.current_domain_port = current_domain_port

local function canonical_url(p)
    local url = ngx.var.scheme .. "://"
    local section = p.section or p.sections[1]
    if section then url = url .. section .. "." end
    url = url .. current_domain_port() .. "/"
    if p.year then url = url .. p.year .. "/" end
    if p.month then url = url .. p.month .. "/" end
    url = url .. p.name
    return url
end
site.canonical_url = canonical_url

local function current_url()
    local url = ngx.var.scheme .. "://" .. ngx.var.host
    local port = current_port()
    if port ~= 80 then url = url .. ":" .. port end
    url = url .. ngx.var.uri
    return url
end
site.current_url = current_url

local function redir_to_canonical(p)
    local url = canonical_url(p)
    if(url ~= current_url()) then ngx.redirect(url) end
end

function M.home()
    ngx.print(t.home.render().body)
    ngx.exit(200)
end

local function archive_month(sect, y, m, top)
        local ym = y..m
        local posts = {}
        for j,p in ipairs(sect.month[ym] or {}) do
            table.insert(posts,t.archive.post(p).body)
        end
        local time = os.time({year=y, month=m, day=1})
        return t.archive.month({y=y,m=m,top=top,header=os.date(top and "%B %Y" or "%B",time),body=posts})
end

local function archive_year(sect, y)
    local archive = {}
    for i,m in ipairs(sect.months[y] or {}) do
        table.insert(archive,(archive_month(sect,y,m,false)).body)
    end
    return t.archive.year({header=y,body=archive})
end

function M.archive()
    if #ngx.var[1] < 1 then ngx.redirect("/archive"..ngx.var.request_uri) end
    local y = ngx.var[2]
    local m = ngx.var[3]
    local sect = cx
    local sd = current_subdomain()
    if sd then
        if cx.section[sd] then
            sect = cx.section[sd]
        else
            sect = {years={},months={},month={}}
        end
    end
    local archive = {}
    if m and #m>1 then
        archive = archive_month(sect,y,m,true)
    elseif y and #y>1 then
        archive = archive_year(sect,y)
    else
        for i,y in ipairs(sect.years) do
            table.insert(archive,(archive_year(sect,y)).body)
        end
        archive = {body=archive}
    end
    archive.section = sd
    ngx.print((t.archive.wrap(archive)).body)
    ngx.exit(200)
end

local function unique_prefix(posts,name)
    local prefixes = 0
    for k,v in pairs(posts) do
        if string.sub(k,1,#name) == name then
            p = v
            prefixes = prefixes + 1
            if prefixes > 1 then break end
        end
    end
    if prefixes == 1 then
        ngx.redirect(canonical_url(p))
    end
    return nil
end

local function getpost(name)
    if(name) then
        local p = cx.posts[name]
        if not p then
            p = unique_prefix(cx.posts,name)
        end
        if p then
            redir_to_canonical(p)
            ngx.print(t.render(p))
            ngx.exit(200)
        end
    end
    ngx.exit(404)
end

function M.post()
    getpost(ngx.var[3])
end

function M.catchall()
    local m = ngx.re.match(ngx.var.uri,[=[/([\w/-]{1,128})(?<!/)]=],"ijo")
    getpost(m and m[1])
end

function M.draft()
    local m = ngx.re.match(ngx.var.uri,[=[drafts?/([\w/-]{1,128})(?<!/)]=],"ijo")
    if m then
        local p = cx.drafts[m[1]]
        if p then
            if p.published then
                redir_to_canonical(p)
            end
            ngx.print(t.render(p))
            ngx.exit(200)
        end
    end
    ngx.exit(404)
end

return M
