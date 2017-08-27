hc_server_responce=("No command "..pl.." found\n-options are onwake_[sleep|alive]")

if  string.find(pl,'onwake_sleep')  and m.onwake_mode=="alive" then
	gpio.mode(m.onwake_pin, gpio.INPUT)
	hc_server_responce=("onwake=sleep")
elseif  string.find(pl,'onwake_alive')  and m.onwake_mode=="sleep" then
	gpio.mode(m.onwake_pin, gpio.OUTPUT)
	gpio.write(m.onwake_pin, gpio.HIGH)
	hc_server_responce=("onwake=alive")
end


if  m.onwake=="enabled" then
	m.onwake="started"

	local onwake = tmr.create()
	onwake:register(100, tmr.ALARM_AUTO, function (t) 
		if(wifi.sta.getip()~=nil) then
			if adc.readvdd33(0) >=4000 then
				remote_cmd(m.onwake_server,m.onwake_cmd_bat_high)
			elseif  adc.readvdd33(0) >= 3500 then
				remote_cmd(m.onwake_server,m.onwake_cmd_bat_ave)
			elseif  adc.readvdd33(0) < 3500 then
				remote_cmd(m.onwake_server,m.onwake_cmd_bat_low)
			end
			t:unregister() 
		end
	end)

	if m.onwake_mode=="alive" then
		local keepalive = tmr.create()
		keepalive:register(4200, tmr.ALARM_SINGLE, function (a) 
	--		gpio.mode(m.onwake_pin, gpio.OUTPUT)
	--		gpio.write(m.onwake_pin, gpio.HIGH)
		onwake:start()
		end)
		keepalive:start()		
	elseif m.onwake_mode=="sleep" then
		local gotosleep = tmr.create()
		gotosleep:register(1000, tmr.ALARM_SINGLE, function (s) 
			if(resp_got~=nil) then 
				s:unregister()
				node.dsleep(0)
			end
		end)
			--gotosleep:start()
	end
	

end


--dofile("m_srv_onwake.lua")
--node.compile("m_srv_onwake.lua")
--print(node.heap())
