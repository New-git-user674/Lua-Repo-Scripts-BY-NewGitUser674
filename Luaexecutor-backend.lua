print("Simple Lua REPL (type 'exit' to quit)")

while true do
    io.write("> ")
    local line = io.read("*l")
    if not line or line == "exit" then break end
    if line ~= "" then
        local chunk, err = load("return " .. line)
        if not chunk then
            chunk, err = load(line)
        end
        if not chunk then
            print("Error: " .. err)
        else
            local ok, result = pcall(chunk)
            if not ok then
                print("Runtime error: " .. result)
            elseif result ~= nil then
                print(result)
            end
        end
    end
end
