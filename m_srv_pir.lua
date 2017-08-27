hc_server_responce=("No command "..pl.." found\nOptions are:\npir_[1-5]_[lights|alarm|disable|status]")	
if string.match(pl, "pir_[1-5]_lights")  then
	pir_no=tonumber(string.sub(pl, 5,5))
	m["pir_"..pir_no.."_state"]="lights"
   	hc_server_responce=("pir_"..pir_no.."_state="..m["pir_"..pir_no.."_state"])
elseif string.match(pl, "pir_[1-5]_alarm")  then
	pir_no=tonumber(string.sub(pl, 5,5))
	m["pir_"..pir_no.."_state"]="alarm"
   	hc_server_responce=("pir_"..pir_no.."_state="..m["pir_"..pir_no.."_state"])
elseif string.match(pl, "pir_[1-5]_disable")  then
	pir_no=tonumber(string.sub(pl, 5,5))
	m["pir_"..pir_no.."_state"]="disabled"
   	hc_server_responce=("pir_"..pir_no.."_state="..m["pir_"..pir_no.."_state"])
elseif string.match(pl, "pir_[1-5]_status")  then
	pir_no=tonumber(string.sub(pl, 5,5))
   	hc_server_responce=("pir_"..pir_no.."_state="..m["pir_"..pir_no.."_state"])
end


if  m.pir=="enabled" then
	m.pir="started"
	for var,val in pairs(m) do
		if string.find(var,'pir_[1-5]$') then
			_G[var.."_function"]=function()	
				if m[var.."_state"] ~="disabled" then
					if gpio.read(val) == 1 and m[var.."_state"] == "lights"  then
						 pir_group=var.."_group_lights_on"
					elseif	gpio.read(val) == 0 and m[var.."_state"] == "lights"  then
						 pir_group=var.."_group_lights_off"
					elseif	gpio.read(val) == 1 and m[var.."_state"] == "alarm"  then
						 pir_group=var.."_group_alarm_on"
					elseif	gpio.read(val) == 0 and m[var.."_state"] == "alarm"  then
						 pir_group=var.."_group_alarm_off"
					end
					for k,v in pairs(_G[pir_group]) do  
						dev,cmd=string.match(k, '(.*)-(.*)')
						_G[v](dev,cmd)
					end
				end
			end
			gpio.mode(val, gpio.INT) 
			gpio.trig(val, 'both', _G[var.."_function"])
		end
	end
end

--dofile("m_srv_pir.lua")
--node.compile("m_srv_pir.lua")
--print(node.heap())
