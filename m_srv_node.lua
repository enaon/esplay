hc_server_responce=("No command "..pl.." found\nOptions are:\nheap,version,role,time[_set],temp,status,vdd,\nwifi(ip,scan,result),file(list,info),recovery,restart")	
if     (pl=="node_heap") then
	hc_server_responce=(node.heap() / 1000 .. " KB left")
elseif (pl=="node_version" and node_version) then
	hc_server_responce=(node_version)
elseif (pl=="node_role" and node_role) then
	hc_server_responce=(node_role)
elseif pl=='node_time' and m.node_time then 
		hc_server_responce=("time="..m.node_time.."\ndate="..m.node_date)
elseif string.find(pl,'node_time_set_') and  m.ds3231 then
		if string.match(pl,'node_time_set_(%d+)-(%d+)-(%d+)-(%d+)-(%d+)-(%d+)-(%d+)') then
			m.node_time_set=pl	hc_server_responce=("new_time_set")			
		else
			hc_server_responce=("wrong format, use node_time_set_sec-min-hour-day-date-month-year")
		end
elseif (pl=="node_temp" and node_temp) then 
	hc_server_responce=(node_temp.." Celcious")
elseif (pl=="node_status") then
	hc_server_responce="no_status_set"
	for var,val in pairs(m) do
		if string.find(var,'state') or string.find(var,'position') or string.find(var,'node_') or string.find(val,'started')then
		--if string.find(var,'pir_[1-5]_state$') or string.find(var,'dimmer_[1-5]_position$') or string.find(var,'dimmer_[1-5]_laststate$') or string.find(var,'blind_[1-5]_position$') or string.find(var,'node_') then
			if temporary_responce then	
				temporary_responce=(temporary_responce.."\n"..var.."="..val)	
			else	temporary_responce=(var.."="..val)	end
		end
	end
	if temporary_responce then
		hc_server_responce=temporary_responce	temporary_responce=nil
	end
elseif (pl=="node_vdd" or adc.force_init_mode(adc.INIT_VDD33) ) then 
--elseif (pl=="node_vdd" or adc.force_init_mode(adc.INIT_ADC) ) then 
--	print("external voltage (mV):", adc.read(0))
--	hc_server_responce=(adc.read(0) / 1000 .. " Volts")
	print("System voltage (mV):", adc.readvdd33(0))
	hc_server_responce=(adc.readvdd33(0) / 1000 .. " Volts")
elseif  string.find(pl,'wifi') then
	if  string.find(pl,'_ip$') then
		if(wifi.sta.getip()==nil) then 
	    		hc_server_responce="Not connected in STA mode"
    	  	else 
			hc_server_responce=("IP of STA interface: "..wifi.sta.getip()) 
	  	end
 	  	if(wifi.ap.getip()==nil) then 
	   		 hc_server_responce=(hc_server_responce.."\nAccess Point Mode is Disabled ")
	  	else
	   		 hc_server_responce=(hc_server_responce.."\nIP of AP interface: "..wifi.ap.getip())
    	 end
	elseif  string.find(pl,'_scan$') then
	  	hc_server_responce="-type: node_wifi_result for scan results"
	  	node_wifi_scan=""
	 	function listap(t)
    	   		for k,v in pairs(t) do
	 			node_wifi_scan=(node_wifi_scan..(k.." : "..v.."\n"))
    	    		end
		end
		wifi.sta.getap(1, listap)
	elseif  (string.find(pl,'_result$') and node_wifi_scan~=nil) then
	  	hc_server_responce=node_wifi_scan
	elseif  (string.find(pl,'_active$') and node_wifimode==3) then
		hc_server_responce="Nodes connected to AP :\n"
		for mac,ip in pairs(wifi.ap.getclient()) do
  			hc_server_responce=(hc_server_responce..(ip.." - "..mac.."\n"))
	  	end
	elseif  string.find(pl,'_mode$')  then
	  	hc_server_responce=wifi.sta.sleeptype()
	else
	  	hc_server_responce=("No option -"..string.sub(pl, 11, 20).."- found.\nOptions are: ip,scan,result,active")
	end
elseif string.find(pl,'file') then
	if  string.find(pl,'list$') then
		hc_server_responce=""
		l = file.list()
 		for k,v in pairs(l) do
  	 		hc_server_responce=(hc_server_responce..("name:"..k..", size:"..v.."\n"))
	  	end
	elseif string.find(pl,'info$') then
	  	remaining, used, total=file.fsinfo()
	  	hc_server_responce=("File system info:\nTotal : "..total.." (k)Bytes\nUsed : "..used.." (k)Bytes\nRemain: "..remaining.." (k)Bytes\n")
	elseif string.find(pl,'remove') then
	  	file.remove(string.sub(pl, 18, 30))
	  	hc_server_responce=("File "..string.sub(pl, 18, 30).." removed\n")
	else	
	  	hc_server_responce=("No option -"..string.sub(pl, 11, 20).."- found.\nOptions are: list,info,remove")
	end
elseif (pl=="node_recovery") then
    	file.remove("boot_status.lua")
	hc_server_responce="-Setting boot flag to recovery and Restarting node\n"
	tmr.alarm(6,2000,0,function() 
	node.restart() 
	end)
	return
elseif (pl=="node_restart") then
       	hc_server_responce="Restarting (normal) node"
	tmr.alarm(6,2000,0,function() 
		node.restart() 
	end)
	return
end
pl=nil

--dofile("m_srv_node.lua")
--node.compile("m_srv_node.lua")
--print(node.heap())