M = {}

local function escape_double_quotes(text)
    local escaped_text = {}
    for _, line in ipairs(text) do
        local escaped_line = line:gsub('"', '\\"')
        table.insert(escaped_text, escaped_line)
    end

    return escaped_text
end

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

local function show_sniptips_picker(opts)
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local finders = require("telescope.finders")
    local make_entry = require("telescope.make_entry")
    local pickers = require("telescope.pickers")
    local previewers = require("telescope.previewers")

    local conf = require("telescope.config").values

    local globbed_files = vim.fn.globpath("/home/anfelo/.sniptip/", "*", true, true)
    local acceptable_files = {}
    for _, v in ipairs(globbed_files) do
        table.insert(acceptable_files, vim.fn.fnamemodify(v, ":t"))
    end

    pickers
        .new(opts, {
            prompt_title = "Snippets",
            finder = finders.new_table({
                results = acceptable_files,
                entry_maker = function(line)
                    return make_entry.set_default_entry_mt({
                        ordinal = line,
                        display = line,
                        filename = "/home/anfelo/.sniptip/" .. line,
                    }, opts)
                end,
            }),
            previewer = previewers.cat.new(opts),
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                    local selection = action_state.get_selected_entry()
                    if selection == nil then
                        print("No selection")
                        return
                    end

                    actions.close(prompt_bufnr)
                    print("Sniptip selected:", selection.display)
                    M.show(selection.display)
                end)

                return true
            end,
        })
        :find()
end

M.init = function()
    if vim.fn.executable("sniptip") == 0 then
        error("sniptip is not installed")
        return
    end

    local cmd = "sniptip init"
    local handle = assert(io.popen(cmd .. " 2>&1"), string.format("Unable to execute cmd - %q", cmd))
    local result = handle:read("*a")
    print(result)

    handle:close()
end

M.show = function(name)
    if vim.fn.executable("sniptip") == 0 then
        error("sniptip is not installed")
        return
    end

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
    if vim.fn.executable("sniptip") == 0 then
        error("sniptip is not installed")
        return
    end

    if name == nil then
        name = vim.fn.input("Enter name: ")
    end

    if name == nil or name == "" then
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

    if string.find(result, "Sniptips not initialized") then
        print(result)

        handle:close()
        return
    end

    print(result)
    handle:close()
end

M.list = function()
    if vim.fn.executable("sniptip") == 0 then
        error("sniptip is not installed")
        return
    end

    local cmd = "sniptip list"
    local handle = assert(io.popen(cmd .. " 2>&1"), string.format("Unable to execute cmd - %q", cmd))
    local result = handle:read("*a")

    if string.find(result, "Sniptips not initialized") then
        print(result)

        handle:close()
        return
    end

    show_sniptips_picker({})

    handle:close()
end

return M
