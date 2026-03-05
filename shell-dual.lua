print("Lua Console with shell support")
print("Prefix commands with ! to run in shell. Type :quit to exit.")

while true do
    io.write("> ")
    local line = io.read("*l")
    if not line then break end

    if line == ":quit" then
        break
    elseif line:sub(1,1) == "!" then
        os.execute(line:sub(2))
    else
        local f, err = load("return " .. line)
        if not f then
            f, err = load(line)
        end
        if not f then
            print("Error:", err)
        else
            local ok, result = pcall(f)
            if not ok then
                print("Runtime error:", result)
            elseif result ~= nil then
                print(result)
            end
        end
    end
end
