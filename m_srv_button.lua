hc_server_responce=("No command "..pl.." found")
if  m.button=="enabled" then 
m.button="started" 
for var,val in pairs(m) do
	if string.find(var,'button_[1-5]$') then
		local id=(string.sub(var, 8, 8))
 		m[var.."_lastpress"]=0
		m[var.."_state"]=0
		_G[var.."_function"]=function(level)
		--print("lala")
			local delay = 50000 
			local now = tmr.now()
			local delta = now - m[var.."_lastpress"]
			if delta < 0 then delta = delta + 2147483647 end
			if delta < delay then  return end
			if gpio.read(m["button_"..id]) == m[var.."_press"] and m[var.."_state"] == 0 then
				m[var.."_state"]=1
				if _G[var.."_group_dn"] then	m[var.."_group"]=var.."_group_dn"	end
				m[var.."_lastpress"] = tmr.now()
			elseif gpio.read(m["button_"..id]) ~= m[var.."_press"] and m[var.."_state"] == 1 then
				m[var.."_state"]=0
				if delta < 250000 and _G[var.."_group_up"] then
					m[var.."_group"]=var.."_group_up"
				elseif _G[var.."_group_long_up"] then
					m[var.."_group"]=var.."_group_long_up"
				end	
			end
			if  m[var.."_group"] then
				for k,v in pairs(_G[m[var.."_group"]]) do
						dev,cmd=string.match(k, '(.*)-(.*)')
						_G[v](dev,cmd)
				end
				m[var.."_group"]=nil
			end
		end  
		
		if m["button_"..id]==8 then 
			gpio.mode(val, gpio.INT)
		else
			gpio.mode(val, gpio.INT, gpio.PULLUP) 
		end
		gpio.trig(val, 'both', _G[var.."_function"])
	end
end
end
--pl=nil
--dofile("m_srv_button.lua")
--node.compile("m_srv_button.lua")
--print(node.heap())