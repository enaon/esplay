upload=net.createServer(net.TCP,10) 
if upload then
	upload:listen(88,function(conn) 
	--conn:on("receive", function(c, fileName) 
	conn:on("receive", receiver)
	end)
end


function reciever(sck, fileName)
	upload_s=sck
  	if (fileName=="file_upload_start")then
  	      conn:send("-Init command recieved, waiting for filename Input\n")
  	      print("-Starting, waiting for filename Input")
  	      upload_mode=1
	elseif (fileName=="file_upload_stop")then
		file.close()
		local send=("-Data transfer ok, now compiling "..savedFile.."\n")
		if savedFile~="init.lua" and savedFile~="init_safe.lua" then
			node.compile(savedFile)
        		file.remove(savedFile)
        		send=(send.."-Finished compiling "..savedFile.."\n")
			if string.match(savedFile, "init_var_.*.lua$") and file.exists("init_var_"..string.match(savedFile, "init_var_(.*).lua$")..".lc")then
				send=(send.."-init_var found, renaming "..string.match(savedFile, "(init_var_.*).lua$")..".lc to init_var.lc\n") 
				file.remove("init_var.lc")
				file.rename("init_var_"..string.match(savedFile, "init_var_(.*).lua$")..".lc","init_var.lc")
			elseif (savedFile=="m_recovery.lua") then
				send=(send.."-m_recovery.lua was updated, restarting node to take effect\n") 
				tmr.alarm(1,1000,0,function() node.restart() end) 
			end
		else
			if savedFile=="init_safe.lua" then file.rename( "init_safe.lua","init.lua") end
			send=(send.."-Skipping compilation of lua.init \n")
		end
		conn:send(send.."-heap: "..node.heap().."\n")
		fileName,savedFile,upload_mode=nil,nil,nil
	elseif (upload_mode==1)then
		conn:send("-got filename : "..fileName.." , recieving data\n-current Heap :"..node.heap().."\n")
		savedFile=fileName
		file.remove(fileName)
		file.open(fileName, "w+")
		upload_mode=2
	elseif (upload_mode==2)then
  	    	 file.writeline(fileName) 
	
  	else 
		conn:send("No command -".. fileName .."- found.\nYou can update configs using:\n./uploadtoesp.sh x.x.x.x xxx.lua\nor node_restart\nto reboot in normal mode\nor file_\n (dangerous)\n")
	
	end

end
--node.compile("m_recovery.lua")