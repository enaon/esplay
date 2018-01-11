print("starting hc server on port 80")
hc_server=net.createServer(net.TCP,10) 
m.node="started"
local_cmd=function(file,input)
		pl=input
		inp=pl
		local _,_,module = string.find(pl, "(%w+)_.*")
		print(module)
		--if module and m[module]~="disabled" and file.exists(("m_srv_"..module..".lc") then
		if module and m[module]=="started" then  
			dofile("m_srv_"..module..".lc")
		elseif  string.find(pl,'GET /') and m.http then
                	dofile("m_srv_http.lc")			
		else 
			hc_server_responce=("No module "..pl.." found\nOptions are:\nnode,dimmer,buzzer,speaker,button,petdoor,blind,car,dist,log,battery\nif enabled in init_starup.lc")	
		end
end
hc_server:listen(80,function(con) 
	con:on("receive", function(con, conin) 
		local_cmd(conin,conin)
		con:send(hc_server_responce.."\n")	
    end) 	
	
	con:on("sent", function(con) 
		if http_end then
			http_end=nil
	--		con:close()
	--		collectgarbage()
		end
		--hc_server_responce=nil
	end)
	
end)
--node.compile("m_srv.lua")