local skynet = require "skynet"

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
		skynet.error(session, source, cmd, subcmd, ...)
    end)	
end)
