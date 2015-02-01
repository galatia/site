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
    table.insert(social_icons,[[<td>]])
    for j,link in ipairs(social_order) do
        table.insert(social_icons, {
            [[<a href="]],social_links[person][link],[[">]],
            [[<img src="social/]],link,[[.png">]],
            [[</a>]]
        })
    end
    table.insert(social_icons,[[</td>]])
end

local bio = [[
  Eliana and davidad like mangos.
]]

function M.render()
    return {
        [[<main>]],
        [[<table>
           <tr>
              <td> davidad photo </td>
              <td> eliana photo </td>
           </tr>
           <tr>
             <th> davidad </th>
             <th> eliana  </th>
           </tr>
           <tr>]],
              social_icons,
           [[</tr>
        </table>]],
        bio,
        [[</main>]]
    }
end

return M
