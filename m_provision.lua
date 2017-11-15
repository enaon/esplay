--provision test


local provision_server,provision_val=10.2.13.66,"test"


local provision = tmr.create()
	provision:register(10000, tmr.ALARM_AUTO, function (t) 
		
    function remote_cmd(provision_server,provision_val)
	rsend = net.createConnection(net.TCP, 0)
	rsend:on("connection",  function(c)
		c:send(provision_val)
	end)
	rsend:on("receive",  function(c,remote_responce)
		provision_responce=remote_responce
		print("recieved from: "..rsrv,provision_responce)
		c:close() 
 	end)
	rsend:connect(87,rsrv)
end





	end)

provision:start()


--print(node.heap())
--node.compile("m_client.lua")