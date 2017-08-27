hc_server_responce=("No command "..pl.." found\n-options are blind_[1-5]_[close[_delay]|open[_delay]|status|toggle[_delay]|set_[0-1000]|laststate_|speedUp|")

if      (string.find(pl,'blind_[1-5]_close') and type(m["blind_"..tonumber(string.sub(pl, 7,7)).."_pin"]) == "number") then
	BLINDno=tonumber(string.sub(pl, 7,7))
	delay=tonumber(string.sub(pl, 15))
   	hc_server_responce=("blind_"..BLINDno.."=closed")
	MoveServo(BLINDno,m["blind_"..BLINDno.."_min"],delay)	m["blind_"..BLINDno.."_state"]="closed"
elseif	(string.find(pl,'blind_[1-5]_open') and type(m["blind_"..tonumber(string.sub(pl, 7,7)).."_pin"]) == "number") then
	BLINDno=tonumber(string.sub(pl, 7,7))
	delay=tonumber(string.sub(pl, 14))
   	hc_server_responce=("blind_"..BLINDno.."=open")
	MoveServo(BLINDno,m["blind_"..BLINDno.."_max"],delay)	m["blind_"..BLINDno.."_state"]="open"
elseif string.find(pl,'blind_[1-5]_status$')  then
	BLINDno=tonumber(string.sub(pl, 7,7))
   	hc_server_responce=("blind_"..BLINDno.."_position="..m["blind_"..BLINDno.."_position"])
elseif string.find(pl,'blind_[1-5]_set_') then
	BLINDno=tonumber(string.sub(pl, 7,7))
	hc_server_responce=("blind_"..BLINDno.."_position="..string.sub(pl, 13,15))
	MoveServo(BLINDno,tonumber(string.sub(pl, 13,15)))
elseif	(string.find(pl,'blind_[1-5]_toggle') and type(m["blind_"..tonumber(string.sub(pl, 7,7)).."_pin"]) == "number") then
	BLINDno=tonumber(string.sub(pl, 7,7))
	delay=tonumber(string.sub(pl, 16))
	if m["blind_"..BLINDno.."_state"]=="closed"  then
	    hc_server_responce=("blind_"..BLINDno.."=open")
		MoveServo(BLINDno,m["blind_"..BLINDno.."_max"],delay) 	
		m["blind_"..BLINDno.."_state"]="open"
	else
       	hc_server_responce=("blind_"..BLINDno.."=closed")
		MoveServo(BLINDno,m["blind_"..BLINDno.."_min"],delay)	
		m["blind_"..BLINDno.."_state"]="closed"
	end
elseif string.find(pl,'blind_[1-5]_speedUp$') then
	BLINDno=tonumber(string.sub(pl, 7,7))	hc_server_responce=("blind_"..BLINDno.."=not moving")
	if _G["blind_tmr_"..BLINDno] ~= nil then 
		_G["blind_tmr_"..BLINDno]:interval(m["blind_"..BLINDno.."_speedUp"]) 
		if m["blind_"..BLINDno.."_state"]=="closed" then
			hc_server_responce=("blind_"..BLINDno.."_position="..m["blind_"..BLINDno.."_min"])
		else
			hc_server_responce=("blind_"..BLINDno.."_position="..m["blind_"..BLINDno.."_max"])
		end
		if m["blind_"..BLINDno.."_laststate"]=="true" and m["blind_"..BLINDno.."_lastvalue"] and  m["blind_"..BLINDno.."_state"]=="open" then
			m.blind_target=m["blind_"..BLINDno.."_lastvalue"]
			hc_server_responce=("blind_"..BLINDno.."_position="..m["blind_"..BLINDno.."_lastvalue"])
		end
	end
elseif string.find(pl,'blind_[1-5]_stop$') then
	BLINDno=tonumber(string.sub(pl, 7,7))	hc_server_responce=("blind_"..BLINDno.."_not moving")
	if _G["blind_tmr_"..BLINDno] ~= nil then 
		_G["blind_tmr_"..BLINDno]:unregister() 
		_G["blind_tmr_"..BLINDno]=nil
		pwm.close(m["blind_"..BLINDno.."_pin"])
		hc_server_responce=("blind_"..BLINDno.."_position="..m["blind_"..BLINDno.."_position"])
	end
end

if  m.blind=="enabled" then
	m.blind="started"
	function MoveServo(BLINDno,target,delay)
		m["blind_"..BLINDno.."_target"]=target
		if delay then	delay=delay*10 end
		if  (_G["blind_tmr_"..BLINDno] == nil) then 
		_G["blind_tmr_"..BLINDno] = tmr.create()
			pwm.setup(m["blind_"..BLINDno.."_pin"], m["blind_"..BLINDno.."_freq"], m["blind_"..BLINDno.."_position"])	-- for walkera (56---240)
		end

		_G["blind_tmr_"..BLINDno]:register(m["blind_"..BLINDno.."_speed"], tmr.ALARM_AUTO, function (t) 
				if m["blind_"..BLINDno.."_target"] == m["blind_"..BLINDno.."_position"] and m["blind_"..BLINDno.."_cont"] ~= "true" then
					if delay then
						delay=delay-1
						if delay==1 then delay=nil end					
					else
						t:unregister() 	
						pwm.close(m["blind_"..BLINDno.."_pin"])
						_G["blind_tmr_"..BLINDno]=nil
					end
				elseif m["blind_"..BLINDno.."_target"] > m["blind_"..BLINDno.."_position"] then
					m["blind_"..BLINDno.."_position"]=m["blind_"..BLINDno.."_position"]+1
				elseif m["blind_"..BLINDno.."_target"] < m["blind_"..BLINDno.."_position"] then
					m["blind_"..BLINDno.."_position"]=m["blind_"..BLINDno.."_position"]-1
				end
				pwm.setduty(m["blind_"..BLINDno.."_pin"],m["blind_"..BLINDno.."_position"])
			end)
		_G["blind_tmr_"..BLINDno]:start()
	end
end

--dofile("m_hc_server_blind.lua")
--node.compile("m_hc_server_blind.lua")
--print(node.heap())