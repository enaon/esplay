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
    m.car_dist_hit=false
	stopFlag=true;
    spdFactor=1
--functions
     --bumper function
	function car_wall_follow_bumper(level)
        spdTargetA,spdTargetB=1023,1023
        tmr.stop(car_tmr_turn)
        tmr.stop(car_tmr_speedup)
        spdFactor=1
        tmr.start(car_tmr_dist_bumper)
		if gpio.read(m.car_bumper)==0 then --we hit something
            gpio.trig(m.car_infra)
            --if distance <= 10 then 
                spdFactor=0.9
                --spdTargetA,spdTargetB=950,1023 --for wheels to the back
			    local_cmd("car_steer_200","car_left")
            --else    
            --    spdFactor=0.9
            --    local_cmd("car_steer_200","car_steer_350")
            --end
		else 			--we released from hitting something
            gpio.trig(m.car_infra,  'both', car_wall_follow_infra)
			if gpio.read(m.car_infra)==0 and distance>=10 and spdFactor==1 then
                spdFactor=0.9
                local_cmd("car_steer_200","car_steer_495")
                tmr.start(car_tmr_speedup)		
			--elseif distance >= 4 then 
                --spdTargetA,spdTargetB=650,1023 --for wheels to the back
                --local_cmd("car_steer_200","car_left")
            --    local_cmd("car_steer_200","car_steer_700")  --for wheels to the back
                --car_tmr_turn:interval(20) --for wheels to the back
            --    tmr.start(car_tmr_turn)
            --elseif distance <4 then
            else
                --if distance >= 5 and m.car_wheels_speed=="high" then
                local_cmd("car_steer_900","car_steer_750")
                tmr.start(car_tmr_turn)


                --spdFactor=0.9
                --spdTargetA,spdTargetB=800,1023 --for wheels to the back
    			--local_cmd("car_steer_200","car_left")
			end
		end
	end


    -- side infra function
	function car_wall_follow_infra()
        --tmr.stop(car_tmr_turn)
        tmr.stop(car_tmr_speedup)
        spdFactor=1      
		spdTargetA,spdTargetB=1023,1023
		if gpio.read(m.car_infra)==0 then
            tmr.stop(car_tmr_turn)
            --spdFactor=0.8 --for wheels to the back
            spdFactor=0.8
            local_cmd("car_steer_200","car_steer_495")
            tmr.start(car_tmr_speedup)	
        else
            local_cmd("car_steer_200","car_steer_750")  --for wheels to the back
            tmr.start(car_tmr_turn)
		end	
	end
		
	
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
    --smooth turn
    car_tmr_turn=tmr.create()    
		tmr.register(car_tmr_turn, 5, tmr.ALARM_AUTO, function () 	
        --spdFactor=1
        spdTargetB=spdTargetB-25
        if spdTargetB<=30 then 
            tmr.stop(car_tmr_turn)
            --spdTargetB=1023
        end
        --local_cmd("car_steer_900","car_steer_1000")
    end)
    -- speed up tmr
    car_tmr_speedup=tmr.create()
	tmr.register(car_tmr_speedup, 500, tmr.ALARM_SEMI, function () 	
        spdFactor=1
    end)
    -- bumper tmr
    car_tmr_dist_bumper=tmr.create()
		tmr.register(car_tmr_dist_bumper,50, tmr.ALARM_AUTO, function () 	
        if m.dist_cont==true and distance <=3 and distance >=0.5 and m.car_dist_hit==false then
            --m.car_dist_hit=true
            spdFactor=0.9
            tmr.stop(car_tmr_turn)
            spdTargetA,spdTargetB=1023,1023 --for wheels to the back
			local_cmd("car_steer_200","car_left")
            --tmr.stop(car_tmr_dist_bumper)
   
        end
    end)
	--wheel speed control 
	car_tmr=tmr.create()
	tmr.register(car_tmr, 20, tmr.ALARM_AUTO, function () 	
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