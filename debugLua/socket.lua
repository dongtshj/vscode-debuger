require "C:/Program Files (x86)/Lua/5.1/lua/socket.lua"

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