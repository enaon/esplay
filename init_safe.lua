--init
--node.setcpufreq(node.CPU80MHZ) -- 'node.CPU80MHZ|node.CPU160MHZ'
boot_status=file.exists("boot_status.lua")
node_version="driot"
--for m_srv.lua and init_var_xxx.lua
m={}
pl=""	
function normal() 
		print("boot status set to normal")
		file.open("boot_status.lua", "w")
		file.write(1)
		file.close()
end

if (boot_status~=true)then
	if file.exists("m_recovery.lc") then dofile("m_recovery.lc") end
else
  	file.remove("boot_status.lua")
	if file.exists("init_var.lc") then  dofile("init_var.lc") set_modules()  init_modules() set_modules,init_modules=nil,nil 	end
 	if file.exists("m_srv.lc") then  dofile("m_srv.lc") end
	if file.exists("m_client.lc") then  dofile("m_client.lc")  end

	init_tmr=tmr.create()
		tmr.register(init_tmr, 500, tmr.ALARM_SINGLE, function () 
		normal()
		init_tmr=nil	
		end)		
	tmr.start(init_tmr)
end
--print(node.heap())
--print(boot_status)