hc_server_responce=("No command "..pl.." found\nOptions are:log_[alarm|error|sensor]_[get|put|clear|clear_all]_[value]\n")	
--log_alarm = file.open("log_alarm.txt", "w")
--log_error = file.open("log_error.txt", "w")
--log_sensor = file.open("log_sensor.txt", "w")

if  string.find(pl,'log_alarm_') then
	if  string.find(pl,'put') and m.log_time=="local" then
		log_alarm = file.open("log_alarm.txt", "a")
		log_alarm:writeline(m.node_date.."."..m.node_time.."-"..string.sub(pl, 15,50 ))
		--log_alarm:seek("set",0)
		log_alarm = file.open("log_alarm.txt", "r")
		hc_server_responce=(log_alarm:read())
		log_alarm:close(); log_alarm= nil
	elseif  string.find(pl,'put')  then	
		hc_server_responce=("no time module enabled")
	elseif  string.find(pl,'get$') then
		if file.exists("log_alarm.txt") then
			log_alarm = file.open("log_alarm.txt", "r")
			hc_server_responce=(log_alarm:read())
			log_alarm:close(); log_alarm= nil
		else
			hc_server_responce=('no_alarms')
		end	
	elseif  string.find(pl,'update') then
		if file.exists("log_alarm.txt") then
				hc_server_responce=("no_valid_entry_to_update")
				log_alarm = file.open("log_alarm.txt", "r")
				repeat
					log_line= log_alarm:readline()
					if log_line and string.match(log_line, "(.*=)%d")==string.match(pl, "log_alarm_update_(.*=)%d" ) then
						log_alarm_position=log_alarm:seek()
						log_alarm:close(); log_alarm= nil
						log_alarm = file.open("log_alarm.txt", "r+")
						log_alarm:seek("set",log_alarm_position-2)
						log_alarm:write(string.match(pl, ".*=(%d)" ))
						log_alarm:seek("set",0)
						hc_server_responce=(log_alarm:read())
						log_alarm:close(); log_alarm= nil
						log_line=nil
						end
				until log_line == nil

		else
			hc_server_responce=('no_alarms_log')
		end	
	elseif  string.find(pl,'clear_all$') then
		file.remove("log_alarm.txt")
		hc_server_responce=('alarms cleared\n')
	end
	if log_alarm then
		log_alarm:close()
		log_alarm = nil
	end

	
	
end
pl=nil

if m.log=="enawbled" then
	m.log="started"
	log_alarm = file.open("log_alarm.txt", "r")
	repeat
		log_line= log_alarm:readline()
		if log_line and string.match(log_line, ".*=(%d)")=="0" then
			print(string.match(log_line, "(.*)=%d"))
			--log_line = nil
		end
	until log_line == nil
end
--dofile("m_srv_log.lua")
--node.compile("m_srv_log.lua")
--print(node.heap())