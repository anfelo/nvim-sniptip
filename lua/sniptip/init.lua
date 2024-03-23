M = {}

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

    -- TODO: paste the result in the current buffer
    print(result)

    handle:close()
end

M.add = function(name, sniptip)
    if name == nil then
        print("sniptip name is required")
        return
    end

    if sniptip == nil then
        print("sniptip is required")
        return
    end

    local cmd = "sniptip add " .. name .. ' "' .. sniptip .. '"'
    local handle = assert(io.popen(cmd .. " 2>&1"), string.format("Unable to execute cmd - %q", cmd))
    local result = assert(handle:read("*a"), "Unable to read the result")

    print(result)
    handle:close()
end

M.add("bubblesort", "function bubblesortSwapped(arr)")

return M
