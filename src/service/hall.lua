local skynet = require "skynet"
local socket = require "socket"
local proxy  = require "socket_proxy"
local manager = require "skynet.manager"

local CMD = {}
local conn = {}
local room_fd = {}

local function read(fd)
	return skynet.tostring(proxy.read(fd))
end

local function hall_work(fd, addr)
	while true do
		local pk, s = pcall(read, fd)
		if not ok then
 			skynet.error("CLOSE")
			break
		end
		if s == "quit" then
			proxy.close(fd)
			break
		end
		print("hall", fd, addr, s)
	end

end

function CMD.go(fd, addr)
	--
	print("cmd gohall", fd, addr)
	local channel = {
		fd = fd,
		addr = addr,
	}
	conn[fd] = channel
end

function CMD.room(fd, addr)
	print("cmd create room", fd, addr)
end
skynet.register_protocol {
	name = "c1",
	id = 111,
--[[
	unpack = function(msg, sz)
		print("unpack", msg, sz)
		return skynet.tostring
	end,
]]
	unpack = skynet.tostring,
	pack = function(m) return tostring(m) end,
	dispatch = function(_, _, type, ...)
		print("dispatch", _, _, type, ...)
	end
}

skynet.start(function()
	skynet.error("hall start")
	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
		skynet.error("hall ", session, source, cmd, subcmd)
		local f = CMD[cmd]
		if f then
		
			skynet.ret(skynet.pack(f(subcmd, ...)))
		else
			print("hall rec", session, source, cmd, subcmd, ...)
			local sss = skynet.unpack(subcmd)
			print("type = ",type(sss), sss.fd)
			print(cmd, subcmd, ...)
			--dispatch_msg(cmd, subcmd, ...)
		end
	end)
--[[
	skynet.dispatch("client", function(session, source, cmd, subcmd, ...)
		print("hall client", session, source, cmd, subcmd, ...)
		--skynet.error("hall ", session, source, cmd, subcmd)
		--local f = assert(CMD[cmd])
		--skynet.ret(skynet.pack(f(subcmd, ...)))
	end)
]]
	manager.register "HALL"
	--skynet.call("SERVER", "lua", "xxx")
end)


