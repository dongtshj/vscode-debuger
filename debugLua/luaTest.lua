require("luaTest2")

print(1)
setfenv(1, {})
print(2)

function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

local g2 = _G

local tab = {1, 2, 3}

local tab_copy = clone(tab)

tab_copy[1] = 1000

local tab_copy2 = clone(tab_copy)

do return end

print(tab[1])

local func1 = function (x)
	print(x)
end

local func2 = function (x)
	x.t = 1
end

local func3 = function (x)
	print(x)
end

func1(7)

func2(99)

print(7)

func3(5)

-- print(module.Add(1, 4))
-- print(module.Sub(1, 4))

-- local file = io.open("test.txt", "w")
-- file:write("aaaaaa")
-- file:close()

do return end

require "socket"

local host = "www.w3.org"
file = "/TR/REC-html32.html"

c = assert(socket.connet(host, 80))

c:send("GET" .. file .. "HTTP/1.0\r\n\r\n")

while true do
	local s, statuss, partial = c:receive(2^10)
	io.write(s or partial)
	if status == "closed" then break end
end

c:close()
