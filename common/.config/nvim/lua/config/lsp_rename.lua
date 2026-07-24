-- lua/config/lsp_rename.lua
-- When a file is renamed or moved OUTSIDE the LSP's own rename command (e.g. from
-- the neo-tree sidebar), the language server never hears about it, so imports that
-- referenced the old path go stale. This helper bridges that gap: it asks every
-- attached server that supports workspace/willRenameFiles to compute the edits
-- (rewrite import paths across the project) and then applies them.
--
-- oil.nvim already does this natively (see plugins/oil.lua's lsp_file_methods);
-- this module is what makes neo-tree behave the same way.

local M = {}

--- Notify LSP servers that `from` has become `to`, and apply the import edits.
---@param from string absolute path of the old file
---@param to string absolute path of the new file
function M.on_rename(from, to)
  if not from or not to or from == to then
    return
  end

  local changes = {
    files = {
      { oldUri = vim.uri_from_fname(from), newUri = vim.uri_from_fname(to) },
    },
  }

  -- 3s, not 1s: computing a rename means the server scans the whole project for
  -- references, which is slow on a large tree / CPU-limited remote. request_sync
  -- BLOCKS the editor for up to this long per capable client, so don't push it too
  -- high — 3s is the balance between "finishes in time" and "noticeable freeze".
  for _, client in ipairs(vim.lsp.get_clients()) do
    if client:supports_method("workspace/willRenameFiles") then
      local resp = client:request_sync("workspace/willRenameFiles", changes, 3000, 0)
      if resp and resp.result then
        vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
      end
    end
  end
end

return M
