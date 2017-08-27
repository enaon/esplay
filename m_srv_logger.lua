hc_server_responce=("No command "..pl.." found\nOptions are:log_[alarm|error|sensor]_[list|\n")	
--log_alarm = file.open("log_alarm.txt", "w")
--log_error = file.open("log_error.txt", "w")
--log_sensor = file.open("log_sensor.txt", "w")
--file.writeline('string')


if  string.find(pl,'log_alarm_') then
	log_alarm = file.open("log_alarm.txt", "a")
	if  string.find(pl,'list$') then
		hc_server_responce=( print(log_alarm:read('\n')))
	end
	log_alarm:close(); 
	log_alarm = nil

elseif string.find(pl,'log_error_') then
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

end
pl=nil

--dofile("m_srv_node.lua")
--node.compile("m_srv_node.lua")
--print(node.heap())