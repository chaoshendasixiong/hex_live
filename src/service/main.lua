local skynet = require "skynet"

skynet.start(function()
	skynet.newservice("console")
	skynet.newservice("debug_console", 11111)
	skynet.newservice("server")
	--skynet.newservice("hall")
	skynet.exit()
end)
