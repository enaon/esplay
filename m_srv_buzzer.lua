hc_server_responce=("No command "..pl.." found\nOptions are:\nbuzzer_[pitch]_[delay]_[repetitions]")	
if string.sub(pl, 1, 7)=="buzzer_"  then
			local bp,bd,br=string.match(pl,'(%d+)_(%d+)_(%d)')		
			buzzer(bp,bd,tonumber(br))
			hc_server_responce=("responce:"..bp..","..bd..","..br)		
end
-- setup
if m.buzzer=="enabled" then
   	m.buzzer="started"
	buzzer_tmr=tmr.create()
	buzzer_tmr_r=tmr.create()
	buzzer=function(bp,bd,br)
	    if buzzer_hold==nil then
		pwm.setup(buzzer_pin, 1000, 512)
		pwm.setduty(buzzer_pin,bp)
		tmr.register(buzzer_tmr, bd, tmr.ALARM_SEMI, function ()
 			pwm.stop(buzzer_pin)
			if br > 0 then
				tmr.register(buzzer_tmr_r, bd, tmr.ALARM_SEMI, function ()
 					pwm.setduty(buzzer_pin,bp)
					br=br-1
					tmr.start(buzzer_tmr)
				end)
				tmr.start(buzzer_tmr_r)
			else pwm.close(buzzer_pin)
			gpio.write(buzzer_pin, gpio.HIGH)
			end
			
		end)
		tmr.start(buzzer_tmr)
		end
	end
end
--dofile("m_srv_buzzer.lua")
--node.compile("m_srv_buzzer.lua")
--print(node.heap())