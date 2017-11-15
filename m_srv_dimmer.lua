hc_server_responce=("No command "..pl.." found\n-options are dimmer_[1-5]_[close|open|status|toggle|set_[0-1000]|laststate_|speedUp|")
--print(pl)

if  string.find(pl,'dimmer_[1-5]_pir$')  then
	dimmer_no=tonumber(string.sub(pl, 8,8))
   	hc_server_responce=("dimmer_"..dimmer_no.."=closed")
	Dimmer(dimmer_no,0)	m["dimmer_"..dimmer_no.."_state"]="closed"
elseif	string.find(pl,'dimmer_[1-5]_toggle$')  then
	dimmer_no=tonumber(string.sub(pl, 8,8))
	if m["dimmer_"..dimmer_no.."_state"]=="closed"  then
	    hc_server_responce=("dimmer_"..dimmer_no.."=open")
		Dimmer(dimmer_no,m.dimmer_max) 	m["dimmer_"..dimmer_no.."_state"]="open"
	else
       	hc_server_responce=("dimmer_"..dimmer_no.."=closed")
		Dimmer(dimmer_no,0)	m["dimmer_"..dimmer_no.."_state"]="closed"
	end
elseif string.find(pl,'dimmer_[1-5]_speedUp$') then
	dimmer_no=tonumber(string.sub(pl, 8,8))	hc_server_responce=("dimmer_"..dimmer_no.."=not_moving")
	if _G["dimmer_tmr_"..dimmer_no] ~= nil then 
		_G["dimmer_tmr_"..dimmer_no]:interval(m.dimmer_speedUp) 
		if m["dimmer_"..dimmer_no.."_state"]=="closed" then
			hc_server_responce=("dimmer_"..dimmer_no.."_position=0")
		else
			hc_server_responce=("dimmer_"..dimmer_no.."_position=999")
			if m["dimmer_"..dimmer_no.."_laststate"]=="true" and m["dimmer_"..dimmer_no.."_lastvalue"]  then
				m["dimmer_"..dimmer_no.."_target"]=m["dimmer_"..dimmer_no.."_lastvalue"]
				hc_server_responce=("dimmer_"..dimmer_no.."_position="..m["dimmer_"..dimmer_no.."_lastvalue"])
			end
		end
	end	
elseif string.find(pl,'dimmer_[1-5]_stop$') then
	dimmer_no=tonumber(string.sub(pl, 8,8))	
	hc_server_responce=("dimmer_"..dimmer_no.."=stopped")
	if _G["dimmer_tmr_"..dimmer_no] ~= nil then 
		_G["dimmer_tmr_"..dimmer_no]:unregister() 
		--_G["dimmer_tmr_"..dimmer_no]=nil
		hc_server_responce=("dimmer_"..dimmer_no.."_position="..m["dimmer_"..dimmer_no.."_position"])
		if m["dimmer_"..dimmer_no.."_position"] > m.dimmer_min then
			m["dimmer_"..dimmer_no.."_lastvalue"]=m["dimmer_"..dimmer_no.."_position"] 
		else
			m["dimmer_"..dimmer_no.."_lastvalue"]=m.dimmer_min
		end
	end
elseif	string.find(pl,'dimmer_[1-5]_open$')  then
	dimmer_no=tonumber(string.sub(pl, 8,8))
   	hc_server_responce=("dimmer_"..dimmer_no.."=open")
	Dimmer(dimmer_no,m.dimmer_max)	m["dimmer_"..dimmer_no.."_state"]="open"
elseif  string.find(pl,'dimmer_[1-5]_close$')  then
	dimmer_no=tonumber(string.sub(pl, 8,8))
   	hc_server_responce=("dimmer_"..dimmer_no.."=closed")
	Dimmer(dimmer_no,0)	m["dimmer_"..dimmer_no.."_state"]="closed"
elseif  string.find(pl,'dimmer_[1-5]_laststate_')  then
	dimmer_no=tonumber(string.sub(pl, 8,8))
	hc_server_responce=("options are: dimmer_[1-5]_laststate_[status|true|false]")
	if  string.find(pl,'dimmer_[1-5]_laststate_status$')  then
	 	hc_server_responce=("dimmer_"..dimmer_no.."_laststate="..m["dimmer_"..dimmer_no.."_laststate"])
	elseif  string.find(pl,'dimmer_[1-5]_laststate_true$')  then
		m["dimmer_"..dimmer_no.."_laststate"]="true"
		hc_server_responce=("dimmer_"..dimmer_no.."_laststate="..m["dimmer_"..dimmer_no.."_laststate"])
	elseif  string.find(pl,'dimmer_[1-5]_laststate_false$')  then
		m["dimmer_"..dimmer_no.."_laststate"]="false"
		hc_server_responce=("dimmer_"..dimmer_no.."_laststate="..m["dimmer_"..dimmer_no.."_laststate"])
	end
elseif	string.find(pl,'dimmer_[1-5]_status$')  then
	dimmer_no=tonumber(string.sub(pl, 8,8))
   	hc_server_responce=("dimmer_"..dimmer_no.."_position="..m["dimmer_"..dimmer_no.."_position"])
	--hc_server_responce=("dimmer_"..dimmer_no.."_"..m["dimmer_"..dimmer_no.."_lastvalue"])
elseif string.find(pl,'dimmer_[1-5]_set_') then
	dimmer_no=tonumber(string.sub(pl, 8,8))
	hc_server_responce=("dimmer_"..dimmer_no.."_position="..string.sub(pl, 14,16))
	m["dimmer_"..dimmer_no.."_lastvalue"]=tonumber(string.sub(pl, 14,16))
	Dimmer(dimmer_no,tonumber(string.sub(pl, 14,16))) m["dimmer_"..dimmer_no.."_state"]="open"
end

if m.dimmer=="enabled" then
	m.dimmer="started"
	function Dimmer(dimmer_no,dimmer_trg)
		m["dimmer_"..dimmer_no.."_target"]=dimmer_trg
		if (_G["dimmer_tmr_"..dimmer_no] == nil) then
			_G["dimmer_tmr_"..dimmer_no] = tmr.create()
			pwm.setup(m["dimmer_"..dimmer_no.."_pin"], m.dimmer_freq, m["dimmer_"..dimmer_no.."_position"])	
		end
		_G["dimmer_tmr_"..dimmer_no]:register(m.dimmer_speed, tmr.ALARM_AUTO, function (t) 
				if m["dimmer_"..dimmer_no.."_target"] == m["dimmer_"..dimmer_no.."_position"]  then
					if m["dimmer_"..dimmer_no.."_position"]==0 then
						_G["dimmer_tmr_"..dimmer_no]:unregister() 
						_G["dimmer_tmr_"..dimmer_no]=nil
					else
						t:unregister() 
					end		
				elseif m["dimmer_"..dimmer_no.."_target"] > m["dimmer_"..dimmer_no.."_position"] then
					m["dimmer_"..dimmer_no.."_position"]=m["dimmer_"..dimmer_no.."_position"]+10
				elseif m["dimmer_"..dimmer_no.."_target"] < m["dimmer_"..dimmer_no.."_position"] then
					m["dimmer_"..dimmer_no.."_position"]=m["dimmer_"..dimmer_no.."_position"]-10
				end
				pwm.setduty(m["dimmer_"..dimmer_no.."_pin"],m["dimmer_"..dimmer_no.."_position"])
		end)
		_G["dimmer_tmr_"..dimmer_no]:start()
	end
	for var,val in pairs(m) do
		local _,_,dmr = string.find(var, "dimmer_(%d)_pin")
		if dmr then
			Dimmer(dmr,m["dimmer_"..dmr.."_position"])
		end
	end
end

--pl=nil
--dofile("m_hc_server_dimmer.lua")
--node.compile("m_srv_dimmer.lua")
--print(node.heap())