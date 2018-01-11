if m.car=="enabled" then
--variables
	--m.car_wheel_lock=1 
    --m.car_wheel_count_state=0
	m.car="started"
    m.car_bumper_lastpress=0
	spdTargetA=1023;--target Speed
	spdCurrentA=0;--current speed
	spdTargetB=1023;--target Speed
	spdCurrentB=0;--current speed
	stopFlag=true;
    m.car_dist_hit=false
    m.car_move_state=""
    spdFactor=1
--functions
    --wall follow bumper function
	function car_wall_follow_bumper()
        spdFactor=1
        spdTargetA,spdTargetB=1023,1023
        tmr.stop(car_tmr_turn_right)
       	if gpio.read(m.car_bumper)==0 then --we hit something
            tmr.start(car_tmr_bumper_hit)
            if distance>=50  then
                local_cmd("car_steer_200","car_steer_200")
            else   
                spdTargetA,spdTargetB=950,1023 
                local_cmd("car_steer_200","car_left")
            end
		else   --we released from hitting something
            tmr.stop(car_tmr_bumper_hit)
            tmr.stop(car_tmr_turn_right)
            if  gpio.read(m.car_infra)==0 and distance>=50 then
                    local_cmd("car_steer_200","car_steer_450")
            else
                    spdTargetA,spdTargetB=850,1023
                    local_cmd("car_steer_200","car_left")
                    car_tmr_turn_right:interval(100)
                    tmr.start(car_tmr_turn_right)
            end
		end
	end
    -- wall follow side infra follow
    lala=0
	function car_wall_follow_infra()
        if  gpio.read(m.car_bumper)==0 or lala==1 then
            lala=1
            spdTargetA,spdTargetB=850,1023
            local_cmd("car_steer_200","car_left")
            car_tmr_turn_right:interval(300)
            tmr.start(car_tmr_turn_right)
            return
        end
        spdFactor=1
        spdTargetA,spdTargetB=1023,1023
        tmr.stop(car_tmr_turn_right)
		if gpio.read(m.car_infra)==0 then
            tmr.start(car_tmr_infra_hit)
                spdFactor=0.9
                local_cmd("car_steer_200","car_steer_450")
        else
                tmr.stop(car_tmr_infra_hit)
                local_cmd("car_steer_200","car_steer_850")
                car_tmr_turn_right:interval(350)
                tmr.start(car_tmr_turn_right)
       	end	
	end
     --
--GPIO defines
    --sensors
    gpio.mode(m.car_bumper,gpio.OUTPUT) --to disable uart
	gpio.mode(m.car_bumper, gpio.INT, gpio.PULLUP)
	gpio.mode(m.car_infra, gpio.INT, gpio.PULLUP)
    --wheels
	gpio.mode(m.car_pwm_1,gpio.OUTPUT);gpio.write(m.car_pwm_1,gpio.LOW)
	gpio.mode(m.car_pwm_2,gpio.OUTPUT);gpio.write(m.car_pwm_2,gpio.LOW)
	gpio.mode(m.car_dir_1,gpio.OUTPUT);gpio.write(m.car_dir_1,gpio.HIGH)
	gpio.mode(m.car_dir_2,gpio.OUTPUT);gpio.write(m.car_dir_2,gpio.HIGH)     
	pwm.setup(m.car_pwm_1,1000,1023) --PWM 1KHz, Duty 1023
	pwm.start(m.car_pwm_1);pwm.setduty(m.car_pwm_1,0)
	pwm.setup(m.car_pwm_2,1000,1023)
	pwm.start(m.car_pwm_2);pwm.setduty(m.car_pwm_2,0)
--timers 
    --for compass
	car_compass_tmr=tmr.create()
	car_compass1_tmr=tmr.create()
    -- after left turn
    car_tmr_turn_right=tmr.create()
	tmr.register(car_tmr_turn_right, 1000, tmr.ALARM_SEMI, function ()
            lala=0            
            spdFactor=1
            spdTargetA,spdTargetB=1023,1023
            local_cmd("car_steer_200","car_steer_950") 
            car_tmr_turn_right:interval(1000)
     end)
    car_tmr_bumper_hit=tmr.create()
	tmr.register(car_tmr_bumper_hit, 150, tmr.ALARM_SEMI, function ()
            spdFactor=1
        --if gpio.read(m.car_bumper)==0 then
             --m.car_move_state="wall_follow"
            --tmr.start(car_tmr_turn_right)
            spdTargetA,spdTargetB=950,1023 --for wheels to the back
            local_cmd("car_steer_200","car_left")
        --end
    end)
    car_tmr_infra_hit=tmr.create()
	tmr.register(car_tmr_infra_hit, 1500, tmr.ALARM_SEMI, function ()
         m.car_move_state="wall_line"
    end)
    car_tmr_wall_line=tmr.create()
	tmr.register(car_tmr_wall_line, 800, tmr.ALARM_SEMI, function ()
        --if gpio.read(m.car_bumper)==0 then
            m.car_move_state="wall_follow"
            tmr.start(car_tmr_turn_right)
            local_cmd("car_steer_200","car_left")
        --end
    end)
	--wheel speed control 
	car_tmr=tmr.create()
	tmr.register(car_tmr, 50, tmr.ALARM_AUTO, function () 	
		if stopFlag==false then
			spdCurrentA=spdTargetA*spdFactor
			spdCurrentB=spdTargetB*spdFactor
			pwm.setduty(m.car_pwm_1,spdCurrentA)
			pwm.setduty(m.car_pwm_2,spdCurrentB)
		else
			pwm.setduty(m.car_pwm_1,0)
			pwm.setduty(m.car_pwm_2,0)
		end
	end)
	tmr.start(car_tmr)
end
--dofile("m_srv_car.lua")
--node.compile("m_srv_car_init.lua")
--print(node.heap())