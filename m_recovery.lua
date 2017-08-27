upload=net.createServer(net.TCP,10) 
upload:listen(88,function(c) 

c:on("receive", function(c, fileName) 
	upload_s=c
  	if (fileName=="file_upload_start")then
  	      c:send("-Init command recieved, waiting for filename Input\n")
  	      print("-Starting, waiting for filename Input")
  	      upload_mode=1
	elseif (fileName=="file_upload_stop")then
		file.close()
		local send=("-Data transfer ok, now compiling "..savedFile.."\n")
		print("-Data transfer ok, now compiling "..savedFile)
		if savedFile~="init.lua" and savedFile~="init_safe.lua" then
			node.compile(savedFile)
        		file.remove(savedFile)
        		send=(send.."-Finished compiling "..savedFile.."\n")
			print("-Finished compiling "..savedFile)
			if string.match(savedFile, "init_var_.*.lua$") and file.exists("init_var_"..string.match(savedFile, "init_var_(.*).lua$")..".lc")then
				send=(send.."-init_var found, renaming "..string.match(savedFile, "(init_var_.*).lua$")..".lc to init_var.lc\n") 
				print("-init_var found, renaming "..string.match(savedFile, "(init_var_.*).lua$")..".lc to init_var.lc\n")
				file.remove("init_var.lc")
				file.rename("init_var_"..string.match(savedFile, "init_var_(.*).lua$")..".lc","init_var.lc")
			elseif (savedFile=="m_recovery.lua") then
				send=(send.."-m_recovery.lua was updated, restarting node to take effect\n") 
				print("-m_recovery.lua was updated, restarting node to take effect\n")
				tmr.alarm(1,1000,0,function() node.restart() end) 
			end
		else
			if savedFile=="init_safe.lua" then file.rename( "init_safe.lua","init.lua") end
			send=(send.."-Skipping compilation of lua.init \n")
			print("-Skipping compilation of lua.init")
		end
		c:send(send.."-heap: "..node.heap().."\n")
		print("-heap: "..node.heap())
		fileName,savedFile,upload_mode=nil,nil,nil
	elseif (upload_mode==1)then
		c:send("-got filename : "..fileName.." , recieving data\n-current Heap :"..node.heap().."\n")
		print("-got filename :"..fileName..", recieving data")
		print("-current Heap :"..node.heap().."\n")
		savedFile=fileName
		file.remove(fileName)
		file.open(fileName, "w+")
		upload_mode=2
	elseif (upload_mode==2)then
    	   	--c:send(">> "..fileName.."\n")
    	  	 --print(fileName.." >> " ..savedFile)
  	    	 file.writeline(fileName) 
	elseif (fileName=="node_restart")then
	        c:send("-Setting boot flag to normal and Restarting node\n")
		print("heap :"..node.heap())
		file.open("boot_status.lua", "w")
		file.write(1)
		file.close()
		tmr.alarm(1,2000,0,function() 
		node.restart() 
		end)
		return
	elseif (fileName=="node_telnet")then	
		if file.exists("m_recovery_telnet.lc") then
			c:send("-going to telnet mode, port 2323\n")
			upload:close()
			dofile("m_recovery_telnet.lc")
			return
		else
			c:send("-no m_recovery_telnet.lc file exists, please upload one\n")
		end
	elseif (string.sub(fileName, 1, 5)=="file_") then
	    if  string.sub(fileName, 1, 9)=="file_list" then
			local send=""
			l = file.list()
			for k,v in pairs(l) do
				send=(send..("name:"..k..", size:"..v.."\n"))
			end
			c:send(send)
		elseif  string.sub(fileName, 1, 9)=="file_info" then
				remaining, used, total=file.fsinfo()
			c:send("File system info:\nTotal : "..total.." (k)Bytes\nUsed : "..used.." (k)Bytes\nRemain: "..remaining.." (k)Bytes\n")
		elseif  string.sub(fileName, 1, 9)=="file_delt" then
			file.remove(string.sub(fileName, 11, 35))
			c:send("File "..string.sub(fileName, 11, 35).." removed\n")
		else	
			c:send("No option -"..string.sub(fileName, 6, 15).."- found.\nOptions are: list,info,delt\n")
		end
  	else 
		c:send("No command -".. fileName .."- found.\nYou can update configs using:\n./uploadtoesp.sh x.x.x.x xxx.lua\nor node_restart\nto reboot in normal mode\nor file_\n (dangerous)\n")
	
	end
 end) 

end)
--node.compile("m_recovery.lua")