local M = {}

local function cowtable(p,t) return setmetatable(t,{__index=p}) end
local function cow(p) return cowtable(p,{}) end
local function cowbody(p,b) return cowtable(p,{body=b}) end
local function datefmt(t)
    if not t then return ""
    else return os.date("%F",t) end
end

local Sections = {"tech", "travel", "curios",
    ["tech"]   = {title = "Technical Journal"},
    ["travel"] = {title = "Travel Notes"},
    ["curios"] = {title = "Cabinet of Curiosity"}
}

local sidebar = {}
function sidebar.link(p)
    return {
        [[<li><a href="]],site.canonical_url(p),[[">]],
        p.title,[[</a></li>]]
    }
end
function sidebar.recents(s,n)
    local recents = {}
    for i,p in ipairs(cx.sections[s] or {}) do
        table.insert(recents,sidebar.link(p))
        if i==n then break end
    end
    return recents
end
function sidebar.section(t)
    local n = t.primary and 4 or 2
    return {
    [[<div class="]],t[1],[[ section panel">]],
    [[<h2>]],(Sections[t[1]] or {title=t[1]}).title,[[</h2>]],
    [[Recent posts:<br/>]],
    [[<ul>]],sidebar.recents(t[1],n),[[</ul>]],
    [[<div class="see-all"><a href="]],
    "//",t[1],".",site.current_domain_port(),"/archive",
    [[">See all</a></div>]],
    [[</div>]]
    }
end
function sidebar.render(t)
    local p = cow(t)
    p.section = p.section or Sections[1]
    local panels = {}
    table.insert(panels,sidebar.section{p.section,primary=true})
    for i,s in ipairs(Sections) do
        if s ~= p.section then
            table.insert(panels,sidebar.section{s})
        end
    end
    if p.section == "tech" then
        table.insert(panels,'<div class="recent repos panel"></div>')
    else
        table.insert(panels,'<div class="recent tweets panel"></div>')
    end
    return {"<nav>",panels,"</nav>"}
end

function M.default(t)
    local p = cow(t)
    p.section = p.section or (p.sections and p.sections[1])
    p.body = {
      [[<html lang="en-US"><head>]],
        [[<meta charset="utf-8">]],
        [[<link href="/index.css" rel="stylesheet" type="text/css">]],
        [[<script src="/index.js"></script>]],
      [[</head>]],
      [[<body class="]],
        section," ",table.concat(p.authors or {}," "),
        [[">]],
      sidebar.render(p),
      p.body,
      [[</body></html>]]
    }
    return p
end

M.home = {
    render = function() return {body = "<h1>Home page</h1>"} end,
    wrap = function(b) return M.default(cowtable(b,{nav=false})) end,
    section = {
        wrap = function(s) return cowbody(s,{"<section><h2>",s.section,"</h2><ul>",s.body,"</ul></section>"}) end,
        post = function(p) return cowbody(p,{
            [[<a href="]],site.canonical_url(p),[["><li>]],datefmt(p.timestamp),[[ <strong>]],p.title,[[</strong></li></a>]]}) end
    }
}

M.archive = {
    wrap = function(b) return M.default(b) end,
    month = function(b) return cowbody(b,{b.top and "<h2>" or {[[<li><a href="/archive/]],b.y,'/',b.m,[["><h3>]]}, b.header, b.top and "</h2>" or "</h3></a>","<ul>", b.body, "</ul>", b.top and "" or "</li>"}) end,
    year = function(b) return cowbody(b,{"<h2>",b.header,"</h2><ul>",b.body,"</ul>"}) end,
    post = M.home.section.post
}

function M.post(p)
    return cowbody(p,{[[
    <div class="]],p.pinned and "pinned " or "",[[post">
    <h1>]],p.title,[[</h1>]],
    [[<div>]],p.body,[[</div>
    </div>]]})
end

function M.render(p)
    return M.default(M.post(p)).body
end

return M
