hc_server_responce=("No command "..pl.." found\nOptions car_{stop|frwd|back|left|right]:\ncar_a_[speeddn|speedup],\ncar_b_[speeddn|speedup]")	


if (pl=="car_stop") then --stop
	pwm.setduty(car_pwm_1,0)
	pwm.setduty(car_pwm_2,0)
	spdTargetA=1023
	spdTargetB=1023
	stopFlag = true;
	hc_server_responce=("car_stop\r");
elseif (pl=="car_frwd") then --forward
	gpio.write(car_dir_1,gpio.HIGH)
	gpio.write(car_dir_2,gpio.HIGH)
	stopFlag = false;
	hc_server_responce=("car_frwd\r");
elseif (pl=="car_back") then --backward
	gpio.write(car_dir_1,gpio.LOW)
	gpio.write(car_dir_2,gpio.LOW)
	stopFlag = false;
	hc_server_responce=("car_back\r");
elseif (pl=="car_left") then --left
	gpio.write(car_dir_1,gpio.LOW)
	gpio.write(car_dir_2,gpio.HIGH)
	stopFlag = false;
	hc_server_responce=("car_left\r");
elseif (pl=="car_right") then --right
	gpio.write(car_dir_1,gpio.HIGH);
	gpio.write(car_dir_2,gpio.LOW);
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
elseif string.find(pl,'car_streer_[0-123456789]')then 
	gpio.write(car_dir_1,gpio.HIGH)
	gpio.write(car_dir_2,gpio.HIGH)
	stopFlag = false;
	local car_steer=tonumber(string.sub(pl, 12, 15))
	if tonumber(string.sub(pl, 12, 15)) >= 513 then
		spdTargetA=1023
		spdTargetB=2046-(car_steer*2)
	elseif tonumber(string.sub(pl, 12, 15)) <= 511 then
		spdTargetB=1023
		spdTargetA=car_steer*2
	elseif tonumber(string.sub(pl, 12, 15)) ==512 then
		spdTargetB=1023
		spdTargetA=1023
	end
	hc_server_responce=("car_steer :"..car_steer.."\r");
elseif (pl=="car_auto_start") then --A spdUp
	CONTINUOUS = true
	measure()
	hc_server_responce=("car_auto_start\r");	
elseif (pl=="car_auto_stop") then --A spdUp
	CONTINUOUS = false

	hc_server_responce=("car_auto_stop\r");	
end


if m.car=="enabled" then

	m.car="started"
	--GPIO Define
	function initGPIO()
--		gpio.mode(0,gpio.OUTPUT);--LED Light on
--		gpio.write(0,gpio.LOW);
		gpio.mode(car_pwm_1,gpio.OUTPUT);gpio.write(car_pwm_1,gpio.LOW);
		gpio.mode(car_pwm_2,gpio.OUTPUT);gpio.write(car_pwm_2,gpio.LOW);
		gpio.mode(car_dir_1,gpio.OUTPUT);gpio.write(car_dir_1,gpio.HIGH);
		gpio.mode(car_dir_2,gpio.OUTPUT);gpio.write(car_dir_2,gpio.HIGH);     
		pwm.setup(car_pwm_1,1000,1023);--PWM 1KHz, Duty 1023
		pwm.start(car_pwm_1);pwm.setduty(car_pwm_1,0);
		pwm.setup(car_pwm_2,1000,1023);
		pwm.start(car_pwm_2);pwm.setduty(car_pwm_2,0);
	end

	print("Start car Control");
		initGPIO();
		spdTargetA=1023;--target Speed
		spdCurrentA=0;--current speed
		spdTargetB=1023;--target Speed
		spdCurrentB=0;--current speed
		stopFlag=true;
	--speed control procedure
	m_car_tmr=tmr.create()
			tmr.register(m_car_tmr, 50, tmr.ALARM_AUTO, function () 	
		if stopFlag==false then
			spdCurrentA=spdTargetA*spdFactor;
			spdCurrentB=spdTargetB*spdFactor;
			pwm.setduty(car_pwm_1,spdCurrentA);
			pwm.setduty(car_pwm_2,spdCurrentB);
		else
			pwm.setduty(car_pwm_1,0);
			pwm.setduty(car_pwm_2,0);
		end
	end)
	tmr.start(m_car_tmr)
end

--dofile("m_srv_car.lua")
--node.compile("m_srv_car.lua")
--print(node.heap())