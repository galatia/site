local M = {}

local ffi = require("ffi")
local c = ffi.load("libcmark")

ffi.cdef[[
  typedef struct cmark_node cmark_node;
  cmark_node* cmark_parse_document(const char* buffer, size_t len);
  char* cmark_render_html(cmark_node* root, long options);
]]

function M.to_html(md_str)
    parse_tree = c.cmark_parse_document(md_str, #md_str)
    html = ffi.string(c.cmark_render_html(parse_tree, 0))
    return html
end

return M
