--functions
-- remote function
remote_cmd_busy=0
function remote_cmd(rsrv,rval)
	rsend = net.createConnection(net.TCP, 0)
	rsend:on("connection",  function(c)
		c:send(rval)
	end)
	rsend:on("receive",  function(c,remote_responce)
		resp_got=remote_responce
		--print("recieved from: "..rsrv,remote_responce)
		--print("reset")
		c:close() 
		remote_cmd_busy=0 
 	end)
	rsend:connect(87,rsrv)
end
--print(node.heap())
--node.compile("m_client.lua")