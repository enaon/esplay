hc_server_responce=("No command "..pl.." found\nOptions dist_[get]_[cont]_[stop]")	
if (pl=="dist_get") then 
hc_server_responce=("distance:"..distance);
elseif (pl=="dist_get_cont") then --stop
m.dist_cont=true
tmr.start(dist_tmr_trigger)
hc_server_responce=("continuous enabled");
elseif (pl=="dist_get_cont_stop") then --stop
m.dist_cont = false
hc_server_responce=("continuous disabled");
end


if m.dist=="enabled" then
	m.dist="started"
	READING_INTERVAL = math.ceil(((max_dist *2/ 340*1000) + m.dist_trig_interval)*1.2)
	time_start,time_stop,distance = 0,0,0
	gpio.mode(m.dist_trig_pin, gpio.OUTPUT)
	gpio.mode(m.dist_echo_pin, gpio.INT)

-- trigger timer
	dist_tmr_trigger_low=tmr.create()
	tmr.register(dist_tmr_trigger_low, m.dist_trig_interval,tmr.ALARM_SEMI, function() 	
		gpio.write(m.dist_trig_pin, gpio.LOW)
    end)
	dist_tmr_trigger=tmr.create()
	tmr.register(dist_tmr_trigger, READING_INTERVAL,tmr.ALARM_AUTO, function() 	
        gpio.write(m.dist_trig_pin, gpio.HIGH)
		tmr.start(dist_tmr_trigger_low)
    end)
-- trigger setup
	gpio.trig(m.dist_echo_pin, "both", function(level)
		if level == 1 then
			time_start = tmr.now()
		else
			time_stop = tmr.now()
			tmr.stop(dist_tmr_trigger)
			local echo_time = (time_stop - time_start) / 1000000
			distance = (echo_time *340 / 2)*100
			if m.dist_cont then
				tmr.start(dist_tmr_trigger)
			end
		end
	end)
end
