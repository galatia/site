local M = {}

local social_order = {"github", "twitter", "linkedin", "email"}
local social_links = {"davidad","eliana",
    davidad = {
        twitter = "https://twitter.com/davidad",
        github  = "https://github.com/davidad",
        linkedin= "https://linkedin.com/in/davidad",
        email   = "http://www.google.com/recaptcha/mailhide/d?k=013z6nJuTj7G_Js1a-V0VMrA==&c=UzaB8wtJQhn2kL5gclpGv2bLGOLVlfrkmxFMkx0hj9I="
    },
    eliana = {
        twitter = "https://twitter.com/elianalorch",
        github  = "https://github.com/galatia",
        linkedin= "https://linkedin.com/in/elianalorch",
        email   = "http://www.google.com/recaptcha/mailhide/d?k=01Uog3bpZNuAzEhW_fLXfEwQ==&c=fZgBZ0D8HvXPfH-ByQM9S47vkZ5ukQy7QCyPqH5Nqio="
    }
}

local social_icons = {}
for i,person in ipairs(social_links) do
    table.insert(social_icons,[[<td><div>]])
    for j,link in ipairs(social_order) do
        table.insert(social_icons, {
            [[<a href="]],social_links[person][link],[[">]],
            [[<img src="social/]],link,[[.png">]],
            [[</a>]]
        })
    end
    table.insert(social_icons,[[</div></td>]])
end

local bio = [[
  <p>davidad and eliana are traveling scientists/<wbr>programmers.</p>
  <p>eliana is a <a href="http://en.wikipedia.org/wiki/Thiel_Fellowship">thiel fellow</a> and davidad is a research affiliate of the <a href="http://syntheticneurobiology.org">synthetic neurobiology</a> group at the <a href="http://web.mit.edu">mit</a> <a href="http://www.media.mit.edu">media lab</a>.</p>
  <p>while we mostly care about the timescale of decades, we like to play around with deep learning, write high-performance code, and explore interesting ideas. we don't like bad software and human aging and maybe we'll try to get rid of them.</p>
]]

function M.render()
    return {
        [[<main><div class="wrapper">]],
        [[<table>
           <tr class="headshots">
              <td><img src="headshots/davidad-1024.jpg"></td>
              <td><img src="headshots/eliana-1024.jpg"></td>
           </tr>
           <tr class="social_icons">]],
              social_icons,
           [[</tr>
        </table>]],
        bio,
        [[</div></main>]]
    }
end

return M
