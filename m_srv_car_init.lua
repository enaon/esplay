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
    m.car_move_state="none"
    m.car_move_log_state="Stoped"
    spdFactor=1
--functions
    --wall follow bumper function
    lala=0
    bumper_hit=0
    last_infra=0
    mode=0
	function car_wall_follow()
        spdFactor=1
        spdTargetA,spdTargetB=1023,1023
        tmr.stop(car_tmr_turn_right)
       	if gpio.read(m.car_bumper)==0 then --we hit something
            if gpio.read(m.car_infra)==0  then
                if distance <= 5 then  bumper_hit=3  else bumper_hit=1 end
            else
                if distance <= 5 then bumper_hit=2 else bumper_hit=1 end
            end
            spdTargetA,spdTargetB=950,1023 
            local_cmd("car_steer_200","car_left")
            tmr.stop(car_tmr_turn_right)
            m.car_move_state=("bhLeft"..bumper_hit)
            m.car_move_log_state=(m.car_move_log_state.." "..m.car_move_state)
            return
		else --infra or released bumper
            tmr.stop(car_tmr_turn_right)
            if distance <=3 then  --if too close ignore and turn
                spdTargetA,spdTargetB=850,1023
                local_cmd("car_steer_200","car_left")
                car_tmr_turn_right:interval(1000)
                tmr.start(car_tmr_turn_right)
                m.car_move_state="diLeft"
                m.car_move_log_state=(m.car_move_log_state.." "..m.car_move_state)
                return
            end
            if bumper_hit>=1 then -- if we just hit something, turn again after release.
                m.car_move_state=("bhiLeft"..bumper_hit)
                car_tmr_turn_right:interval(600*(bumper_hit+1)
                bumper_hit=bumper_hit-1
                tmr.start(car_tmr_turn_right)
                spdTargetA,spdTargetB=850,1023 
                local_cmd("car_steer_200","car_left")
                m.car_move_log_state=(m.car_move_log_state.." "..m.car_move_state)
                return
            end
            if  gpio.read(m.car_infra)==0  then
                if mode >= 15 and distance >=50 then
                    local_cmd("car_steer_200","car_steer_465")
                else
                    if   m.car_move_state=="right" then
                        spdFactor=0.85
                        m.car_move_state="st485s"
                    else 
                        m.car_move_state="st485"
                    end
                    local_cmd("car_steer_200","car_steer_485")
                    --spdFactor=0.9
                    --mode=mode+1
                end
                 
            else    
                if  mode >= 15 and distance >=50 then
                    local_cmd("car_steer_200","car_steer_750")
                    car_tmr_turn_right:interval(1000)
                elseif distance >=5150 then
                    local_cmd("car_steer_200","car_steer_850")
                    car_tmr_turn_right:interval(300)
                else   
                    local_cmd("car_steer_200","car_steer_850")
                    car_tmr_turn_right:interval(300)
                    --mode=mode+1
                end
                tmr.start(car_tmr_turn_right)
                 m.car_move_state="steer_850"

            end
            m.car_move_log_state=(m.car_move_log_state.." "..m.car_move_state)
		end
	end
    -- wall follow side infra follow
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
    -- distance
    car_tmr_distance=tmr.create()
	tmr.register(car_tmr_distance, 50, tmr.ALARM_AUTO, function ()
    local dist_mode
            if distance <=2.9 and dist_mode~="turn" then
                dist_mode="turn"
                tmr.stop(car_tmr_turn_right)
                if gpio.read(m.car_infra)==0 then  bumper_hit=2  else  bumper_hit=1  end
                spdTargetA,spdTargetB=850,1023
                local_cmd("car_steer_200","car_left")
                car_tmr_turn_right:interval(1000)
                tmr.start(car_tmr_turn_right)
                m.car_move_state=("dhLeft"..bumper_hit)
                m.car_move_log_state=(m.car_move_log_state.." "..m.car_move_state)
            elseif distance <= 10 and dist_mode~="low" then
                spdFactor=0.8
                dist_mode="low"

            elseif distance <= 20 and dist_mode~="med" then
                spdFactor=0.9
                dist_mode="med"
            end
     end)
    -- right turn
    car_tmr_turn_right=tmr.create()
	tmr.register(car_tmr_turn_right, 1000, tmr.ALARM_SEMI, function ()
            car_tmr_turn_right:interval(1000)
            spdTargetA,spdTargetB=1023,450
            spdFactor=0.9
            local_cmd("car_steer_200","car_right")
            --local_cmd("car_steer_200","car_steer_1023")
             m.car_move_state="right"
             m.car_move_log_state=(m.car_move_log_state.." "..m.car_move_state)
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