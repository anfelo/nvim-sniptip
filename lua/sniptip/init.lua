M = {}

local function escape_double_quotes(text)
    local escaped_text = {}
    for _, line in ipairs(text) do
        local escaped_line = line:gsub('"', '\\"')
        table.insert(escaped_text, escaped_line)
    end

    return escaped_text
end

-- Function to trim indentation of selected text
local function trim_indentation(selected_text)
    -- Find the minimum indentation level among all lines
    local min_indent = math.huge
    for _, line in ipairs(selected_text) do
        local indent = line:match("^%s*")
        if indent then
            min_indent = math.min(min_indent, #indent)
        end
    end

    -- Remove the minimum indentation level from each line
    local trimmed_text = {}
    for _, line in ipairs(selected_text) do
        local trimmed_line = line:sub(min_indent + 1)
        table.insert(trimmed_text, trimmed_line)
    end

    return trimmed_text
end

M.init = function()
    local cmd = "sniptip init"
    local handle = assert(io.popen(cmd .. " 2>&1"), string.format("Unable to execute cmd - %q", cmd))
    local result = handle:read("*a")
    print(result)

    handle:close()
end

M.show = function(name)
    if name == nil then
        print("sniptip name is required")
        return
    end

    local cmd = "sniptip show " .. name
    local handle = assert(io.popen(cmd .. " 2>&1"), string.format("Unable to execute cmd - %q", cmd))
    local result = handle:read("*a")

    if string.find(result, "Sniptips not initialized") or string.find(result, "Unable to access sniptip") then
        print(result)

        handle:close()
        return
    end

    vim.api.nvim_paste(result, true, -1)

    handle:close()
end

M.add = function(name)
    if name == nil then
        print("sniptip name is required")
        return
    end

    local buf = vim.api.nvim_get_current_buf()
    local start_pos = vim.api.nvim_buf_get_mark(buf, "<")
    local end_pos = vim.api.nvim_buf_get_mark(buf, ">")
    local sniptip = vim.api.nvim_buf_get_lines(buf, start_pos[1] - 1, end_pos[1], false)

    sniptip = escape_double_quotes(sniptip)
    sniptip = trim_indentation(sniptip)
    sniptip = table.concat(sniptip, "\n")

    local cmd = "sniptip add " .. name .. ' "' .. sniptip .. '"'
    local handle = assert(io.popen(cmd .. " 2>&1"), string.format("Unable to execute cmd - %q", cmd))
    local result = assert(handle:read("*a"), "Unable to read the result")

    print(result)
    handle:close()
end

M.add("bubblesort")

return M
