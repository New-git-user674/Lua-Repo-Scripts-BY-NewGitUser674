local Compiler = require("toy_compiler")

local expr = "10 + 20 * (3 - 1)"
local f = Compiler.compile(expr)
print("Result:", f())
