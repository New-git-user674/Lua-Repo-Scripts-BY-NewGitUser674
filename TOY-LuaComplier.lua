-- toy_compiler.lua
-- A tiny expression language compiler written in Lua
-- Grammar:
--   expr   -> term (('+' | '-') term)*
--   term   -> factor (('*' | '/') factor)*
--   factor -> NUMBER | '(' expr ')'

local Compiler = {}

-- ========== Lexer ==========

local function tokenize(input)
    local tokens = {}
    local i = 1
    local len = #input

    local function is_space(c)
        return c == ' ' or c == '\t' or c == '\n' or c == '\r'
    end

    local function is_digit(c)
        return c and c:match('%d') ~= nil
    end

    while i <= len do
        local c = input:sub(i, i)

        if is_space(c) then
            i = i + 1

        elseif c == '+' or c == '-' or c == '*' or c == '/' or c == '(' or c == ')' then
            table.insert(tokens, { type = c, value = c })
            i = i + 1

        elseif is_digit(c) then
            local start = i
            while i <= len and is_digit(input:sub(i, i)) do
                i = i + 1
            end
            local num_str = input:sub(start, i - 1)
            table.insert(tokens, { type = "NUMBER", value = tonumber(num_str) })

        else
            error("Unexpected character: " .. c)
        end
    end

    table.insert(tokens, { type = "EOF" })
    return tokens
end

-- ========== Parser ==========

local Parser = {}
Parser.__index = Parser

function Parser:new(tokens)
    return setmetatable({ tokens = tokens, pos = 1 }, self)
end

function Parser:current()
    return self.tokens[self.pos]
end

function Parser:eat(type_)
    local tok = self:current()
    if tok.type == type_ then
        self.pos = self.pos + 1
        return tok
    else
        error("Expected token " .. type_ .. " but got " .. tok.type)
    end
end

-- factor -> NUMBER | '(' expr ')'
function Parser:parse_factor()
    local tok = self:current()
    if tok.type == "NUMBER" then
        self:eat("NUMBER")
        return { kind = "number", value = tok.value }
    elseif tok.type == "(" then
        self:eat("(")
        local node = self:parse_expr()
        self:eat(")")
        return node
    else
        error("Unexpected token in factor: " .. tok.type)
    end
end

-- term -> factor (('*' | '/') factor)*
function Parser:parse_term()
    local node = self:parse_factor()

    while true do
        local tok = self:current()
        if tok.type == "*" or tok.type == "/" then
            self:eat(tok.type)
            node = {
                kind = "binop",
                op = tok.type,
                left = node,
                right = self:parse_factor()
            }
        else
            break
        end
    end

    return node
end

-- expr -> term (('+' | '-') term)*
function Parser:parse_expr()
    local node = self:parse_term()

    while true do
        local tok = self:current()
        if tok.type == "+" or tok.type == "-" then
            self:eat(tok.type)
            node = {
                kind = "binop",
                op = tok.type,
                left = node,
                right = self:parse_term()
            }
        else
            break
        end
    end

    return node
end

function Parser:parse()
    local node = self:parse_expr()
    if self:current().type ~= "EOF" then
        error("Unexpected tokens after expression")
    end
    return node
end

-- ========== Code Generator ==========

local function generate_expr(ast)
    if ast.kind == "number" then
        return tostring(ast.value)
    elseif ast.kind == "binop" then
        local left = generate_expr(ast.left)
        local right = generate_expr(ast.right)
        return "(" .. left .. " " .. ast.op .. " " .. right .. ")"
    else
        error("Unknown AST node kind: " .. tostring(ast.kind))
    end
end

-- Compile expression string to a Lua function that returns the result
function Compiler.compile(expr_str)
    local tokens = tokenize(expr_str)
    local parser = Parser:new(tokens)
    local ast = parser:parse()

    local lua_expr = generate_expr(ast)
    local lua_src = "return function()\n  return " .. lua_expr .. "\nend"

    local chunk, err = load(lua_src, "compiled_expr", "t", {})
    if not chunk then
        error("Compilation error: " .. err)
    end

    local fn_factory = chunk()
    return fn_factory()
end

-- ========== Example usage ==========

-- local expr = "1 + 2 * (3 + 4) - 5"
-- local f = Compiler.compile(expr)
-- print("Expression:", expr)
-- print("Result:", f())  -- should print 10

return Compiler
