hc_server_responce=("No command "..pl.." found\n-options are battery_[status|details|log_[put|get|clear|clear_all]]")

if  string.find(pl,'battery_status')  then
	hc_server_responce=("battery_state="..m.battery_state.."-"..adc.readvdd33(0)/1000 .. "V")
elseif  string.find(pl,'battery_details$') then
		if file.exists("log_battery.txt") and m.battery_run~=1  then
			log_inq()
			if m.battery_voltage_last and m.battery_voltage_last~=m.battery_voltage_start then 
			m.battery_freq=m.battery_loop/60000
			local battery_uptime=m.battery_freq*m.battery_run
			local battery_days,battery_hours,battery_mins=0,0,0
			repeat
				if battery_uptime>=60 then 
					battery_hours=battery_hours+1
					battery_uptime=battery_uptime-60
					if battery_hours>=24 then
						battery_days=battery_days+1
						battery_hours=battery_hours-24
					end
				end
			until battery_uptime < 60
			battery_mins=battery_uptime
			local battery_uptime=m.battery_freq*m.battery_run
			local battery_remain_uptime=((m.battery_voltage_last-3300)/(m.battery_voltage_start-m.battery_voltage_last))*battery_uptime
			local battery_remain_days,battery_remain_hours,battery_remain_mins=0,0,0
			repeat
				if battery_remain_uptime>=60 then 
					battery_remain_hours=battery_remain_hours+1
					battery_remain_uptime=battery_remain_uptime-60
					if battery_remain_hours>=24 then
						battery_remain_days=battery_remain_days+1
						battery_remain_hours=battery_remain_hours-24
					end
				end
			until battery_remain_uptime < 60
			battery_remain_mins=battery_remain_uptime
			hc_server_responce=("uptime="..battery_days.."days/"..battery_hours.."hours/"..battery_mins.."minutes\nvoltage="..m.battery_voltage_last.."\nremain="..battery_remain_days.."days/"..battery_remain_hours.."hours/"..battery_remain_mins.."minutes")
			m.battery_state_detail=hc_server_responce
			else
				hc_server_responce=('error found in stats\n')
			end
		elseif m.battery_run==1 then 
			hc_server_responce=('please wait for stats\n')
		end	
elseif  string.find(pl,'battery_log_') then
	local localpl=pl
	if  string.find(localpl,'put')  then
		log_battery = file.open("log_battery.txt", "w")
		log_battery:writeline("1-init-"..m.battery_voltage_start.."mV")
		log_battery:writeline(m.battery_run.."-"..string.sub(localpl, 17,50 ))
		log_battery:close(); log_battery= nil
		hc_server_responce=('entry_added')
	elseif  string.find(localpl,'get$') then
		if file.exists("log_battery.txt") then
			log_battery = file.open("log_battery.txt", "r")
			hc_server_responce=(log_battery:read())
			log_battery:close(); log_battery= nil
		else
			hc_server_responce=('no_logs')
		end	
	elseif  string.find(localpl,'clear_all$') then
		log_init()
		hc_server_responce=('alarms cleared\n')
	end
end

if  m.battery=="enabled" then
	m.battery="started"
	--
	function log_init()
		m.battery_run=1
		m.battery_voltage_start=adc.readvdd33(0)
		m.battery_voltage_last=m.battery_voltage_start
		log_battery=file.open("log_battery.txt", "w")
		log_battery:writeline("1-init-"..m.battery_voltage_start.."mV")
		log_battery:close(); log_battery=nil
	end
	function log_inq()
		log_battery=file.open("log_battery.txt", "r")
		repeat
			local log_line=log_battery:readline()
			if m.battery_voltage_start==nill and log_line and string.match(log_line, '1%-%a+%-(%d+)mV') then
				m.battery_voltage_start=string.match(log_line, '1%-%a+%-(%d+)mV')
			elseif log_line and string.match(log_line, '[^1]%-%a+%-(%d+)mV') then
				m.battery_run,m.battery_voltage_last=string.match(log_line, '(%d+)%-%a+%-(%d+)mV')
			end
		until log_line == nil
		log_battery:close(); log_battery= nil
		log_line=nil
	end
--
	if file.exists("log_battery.txt") then
		log_inq()
		local battery_now=adc.readvdd33(0)
		if (m.battery_voltage_last and battery_now>=m.battery_voltage_last+200) or  battery_now>=4250 then
			log_init()
		end
	else
		log_init()
	end
--	
	battery_tmr=tmr.create()
	battery_tmr:register(m.battery_loop, tmr.ALARM_AUTO, function (t) 
	    local battery_now=adc.readvdd33(0)
		m.battery_run=m.battery_run+1
		if	battery_now >= 4100 then	
			m.battery_state="charging"
			if battery_state_charging then	m.battery_group=battery_state_charging end
		elseif battery_now <= 2800 then
			m.battery_state="power_down"
		elseif battery_now <= 3000 then
			m.battery_state="critical"
			if battery_state_critical then	m.battery_group=battery_state_critical end
		elseif battery_now <= 3400 then
			m.battery_state="low"
			if battery_state_low then	m.battery_group=battery_state_low end
		elseif battery_now <= 3700 then
			m.battery_state="medium"
			if battery_state_medium then	m.battery_group=battery_state_medium end
		elseif battery_now <= 4100 then
			m.battery_state="high"
			if battery_state_high then	m.battery_group=battery_state_high end
		end
		if  m.battery_group then
				for k,v in pairs(m.battery_group) do
						dev,cmd=string.match(k, '(.*)-(.*)')
						_G[v](dev,cmd)
				end
				m.battery_group=nil
		end
		local_cmd(battery,("battery_log_put_"..m.battery_state.."-"..adc.readvdd33(0) .."mV"))
		--local_cmd(battery,"battery_details")
	end)
	battery_tmr:start()
--
end	
--dofile("m_srv_battery.lua")
--node.compile("m_srv_battery.lua")
--print(node.heap())