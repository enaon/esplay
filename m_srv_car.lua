hc_server_responce=("No command "..pl.." found\nOptions car_{stop|frwd|back|left|right]:\ncar_a_[speeddn|speedup],\ncar_b_[speeddn|speedup]")	


if (pl=="car_stop") then --stop
	pwm.setduty(m.car_pwm_1,0)
	pwm.setduty(m.car_pwm_2,0)
	spdTargetA=1023
	spdTargetB=1023
	stopFlag = true;
	hc_server_responce=("car_stop\r");
elseif (pl=="car_frwd") then --forward
	gpio.write(m.car_dir_1,gpio.HIGH)
	gpio.write(m.car_dir_2,gpio.HIGH)
	stopFlag = false;
	hc_server_responce=("car_frwd\r");
elseif (pl=="car_back") then --backward
	gpio.write(m.car_dir_1,gpio.LOW)
	gpio.write(m.car_dir_2,gpio.LOW)
	stopFlag = false;
	hc_server_responce=("car_back\r");
elseif (pl=="car_left") then --left
	gpio.write(m.car_dir_1,gpio.LOW)
	gpio.write(m.car_dir_2,gpio.HIGH)
	stopFlag = false;
	hc_server_responce=("car_left\r");
elseif (pl=="car_right") then --right
	gpio.write(m.car_dir_1,gpio.HIGH);
	gpio.write(m.car_dir_2,gpio.LOW);
	stopFlag = false;
	hc_server_responce=("car_right\r");
elseif (pl=="car_a_spdup") then --A spdUp
	spdTargetA = spdTargetA+50;if(spdTargetA>1023) then spdTargetA=1023;end
	hc_server_responce=("car_a_spdup\r");
elseif (pl=="car_a_spddn") then --A spdDown
	spdTargetA = spdTargetA-50;if(spdTargetA<0) then spdTargetA=0;end
	hc_server_responce=("car_a_spddn\r");
elseif (pl=="car_b_spdup") then --B spdUp
	spdTargetB = spdTargetB+50;if(spdTargetB>1023) then spdTargetB=1023;end
	hc_server_responce=("car_b_spdup\r");
elseif (pl=="car_b_spddn") then --B spdDown
	spdTargetB = spdTargetB-50;if(spdTargetB<0) then spdTargetB=0;end
	hc_server_responce=("car_b_spddn\r");     
elseif string.find(pl,'car_speed_[10-99]')then --A spd set
	spdFactor = tonumber(string.sub(pl, 11, 12))/100
	hc_server_responce=("car_spdFactor_"..spdFactor.."\r");
elseif string.find(pl,'car_steer_[0-123456789]')then 
	gpio.write(m.car_dir_1,gpio.HIGH)
	gpio.write(m.car_dir_2,gpio.HIGH)
	stopFlag = false;
	local car_steer=tonumber(string.sub(pl, 11, 15))
	if car_steer >= 513 then
		spdTargetA=1023
		spdTargetB=2048-(car_steer*2)
	elseif car_steer <= 511 then
		spdTargetB=1023
		spdTargetA=car_steer*2
	elseif car_steer ==512 then
		spdTargetB=1023
		spdTargetA=1023
	end
	hc_server_responce=("car_steer :"..car_steer.."\r");
elseif (pl=="car_compass_on") then --auto drive
	car_compass_tmr:register(150, tmr.ALARM_AUTO, function(t) 
		if m.compass_state<m.car_compass_dir-50 then
		    spdTargetA,spdTargetB=1023,150
			--local_cmd("car_steer_1000","car_steer_1020")
			local_cmd("car_steer_200","car_right")
		elseif m.compass_state>m.car_compass_dir+50 then
            spdTargetA,spdTargetB=150,1023
			--local_cmd("car_steer_200","car_steer_1")
			local_cmd("car_steer_200","car_left")
		elseif m.compass_state<m.car_compass_dir-10 then
			
			local_cmd("car_steer_200","car_steer_900")
		elseif m.compass_state>m.car_compass_dir+10 then
            spdTargetA,spdTargetB=700,1023
			local_cmd("car_steer_200","car_steer_100")
		elseif m.compass_state<m.car_compass_dir-1 then
			local_cmd("car_steer_200","car_steer_600")
		elseif m.compass_state>m.car_compass_dir+1 then
			local_cmd("car_steer_200","car_steer_400")
		else
			local_cmd("car_steer_512","car_steer_512")
		end
	end)
	car_compass_tmr:start()
	hc_server_responce=("car_compass_on");
elseif (pl=="car_compass_up") then --auto drive
	m.car_compass_dir=m.car_compass_up
	hc_server_responce=("car_compass_up");
elseif (pl=="car_compass_dn") then --auto drive
	m.car_compass_dir=m.car_compass_dn	
	hc_server_responce=("car_compass_dn");
elseif (pl=="car_compass_off") then --auto drive
	--if  car_compass_tmr then
		car_compass_tmr:stop()
		car_compass1_tmr:stop()
		local_cmd("car_steer_512","car_stop")
	--end
	hc_server_responce=("car_compass_off:"..m.compass_state);
-- wall follow
elseif string.find(pl,'car_wall_start')then 
	gpio.trig(m.car_bumper,  'both' , car_wall_follow)
	gpio.trig(m.car_infra,  'both' , car_wall_follow)
	m.car_move_log_state="Started"
	--tmr.start(car_tmr_dist_bumper)
	hc_server_responce=("car_wall_start");
elseif string.find(pl,'car_wall_stop')then 
	gpio.trig(m.car_bumper)
	gpio.trig(m.car_infra)
	hc_server_responce=("car_wall_stop");
--
elseif string.find(pl,'car_wheel_start')then 
	gpio.trig(m.car_wheel,  'down', car_wheel)
	hc_server_responce=("car_wheel_start");
elseif string.find(pl,'car_wheel_stop')then 
	gpio.trig(m.car_wheel)	
	hc_server_responce=("car_wheel_stop");
elseif string.find(pl,'car_wheel_reset')then 
	m.car_wheel_count_state=0	
	hc_server_responce=("car_wheel_reset");
elseif string.find(pl,'car_dist_start')then 
	tmr.start(car_tmr_distance)
	hc_server_responce=("car_dist_start");
elseif string.find(pl,'car_dist_stop')then 
	tmr.stop(car_tmr_distance)
	hc_server_responce=("car_dist_stop");	
elseif string.find(pl,'car_brush_on')then 
	remote_cmd("192.168.51.2","dimmer_3_set_800")
	hc_server_responce=("car_brush_on");
elseif string.find(pl,'car_brush_off')then 
	remote_cmd("192.168.51.2","dimmer_3_close")
	hc_server_responce=("car_brush_off");
elseif string.find(pl,'car_roller_on')then 
	remote_cmd("192.168.51.2","dimmer_2_set_800")
	hc_server_responce=("car_roller_on");
elseif string.find(pl,'car_roller_off')then 
	remote_cmd("192.168.51.2","dimmer_2_close")
	hc_server_responce=("car_roller_off");
elseif string.find(pl,'car_vacuum_on')then 
	remote_cmd("192.168.51.2","dimmer_1_open")
	hc_server_responce=("car_vacuum_on");
elseif string.find(pl,'car_vacuum_off')then 
	remote_cmd("192.168.51.2","dimmer_1_close")
	hc_server_responce=("car_vacuum_off");
end



--dofile("m_srv_car.lua")
--node.compile("m_srv_car.lua")
--print(node.heap())