--本服务只负责解析消息和转发消息
local skynet = require "skynet"

local socket = require "socket"
local proxy  = require "socket_proxy"

local status = {}

local no_auth = 0
local hall


skynet.start(function()
	local id = assert(socket.listen(skynet.getenv "server_ip",
		skynet.getenv "server_port"))
	socket.start(id, function(fd, addr)
		skynet.error("client="..fd, " ["..addr.."]", "connected")
		--skynet.fork(work, fd, addr)
		work_(fd,addr)
	end)
	hall = skynet.newservice("hall")
end)

local function read(fd)
	return skynet.tostring(proxy.read(fd))
end


local function do_auth(fd, addr, s)
	status[fd].status = hall
	print("go hall success")
end

local function do_hall(fd, addr, s)
	--skynet.redirect("HALL", skynet.self(), "lua", 0, s, #s)
	--skynet.send("HALL", "lua", s,fd,addr)
	local ssss = skynet.packstring({s = s, fd = fd, addr = addr})
	print(ssss)
	skynet.send("HALL", "lua", ssss)
	--skynet.redirect(status[fd].status,skynet.self(),  "lua",0,  s)
	print("redirect hall client", s)
end
--[[
skynet.register_protocol {
	name = "c1",
	id = 111,
}
]]


local function dispatch(fd, addr, s)
	if status[fd].status == no_auth then
		do_auth(fd, addr, s)

	elseif status[fd].status == hall then
		do_hall(fd, addr, s)	

	end
--[[
		if s == "a" then
			print("auth success")
			--模拟认证通过 发送fd到hall 消息由hall接管 
			skynet.send("HALL", "lua", "go", fd, addr)
		elseif s == "b" then
			--模拟开始游戏 创建玩家房间服务 随后消息全部转发到room
			--skynet.send("HALL", "lua", "room", fd, addr)
			local room = skynet.newservice("room")
			room[fd] = room
		end
]]
end
function work_(fd, addr)
	local c = {}
	c.status = no_auth
	status[fd] = c
	--print(fd, addr)
	proxy.subscribe(fd)
	--print(proxy.info(fd))
	while true do
		local ok, s = pcall(read, fd)
		if not ok then
			skynet.error("CLOSE")
			break
		end
		if s == "quit" then
			proxy.close(fd)
			break
		end
		--skynet.error(s)
		--socket.write(fd, s)
		--proxy.write(fd, s, #s)
		--print(proxy.info(fd))
		dispatch(fd, addr, s)
	end

end

function work(id, addr)
	socket.start(id)
	while true do
		local str = socket.read(id)
		if str then
			skynet.error(id, str)
			dispatch(id, str)
		else
			socket.close(id)
			skynet.error(id, "disconnected")
		end
	end

end
