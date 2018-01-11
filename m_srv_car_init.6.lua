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
    spdFactor=1
--functions
     --bumper function
	function car_wall_follow_bumper(level)
        spdTargetA,spdTargetB=1023,1023
        tmr.stop(car_tmr_turn_right)
        tmr.stop(car_tmr_speedup)
        tmr.stop(car_tmr_after_left)
        tmr.stop(car_tmr_dist_bumper)
     	if gpio.read(m.car_bumper)==0 then --we hit something
            gpio.trig(m.car_infra)
            if spdFactor==1 and distance >=50 then
                local_cmd("car_steer_200","car_steer_300")
            else
                m.car_dist_hit=false
                spdTargetA,spdTargetB=950,1023 --for wheels to the back
                local_cmd("car_steer_200","car_left")
            end
		else    --we released from hitting something
            gpio.trig(m.car_infra,  'both', car_wall_follow_infra)
            tmr.start(car_tmr_dist_bumper)
			if gpio.read(m.car_infra)==0 and distance>=10 and spdFactor==1 then
                local_cmd("car_steer_200","car_steer_485")
                tmr.start(car_tmr_speedup)		
            else
                spdTargetA,spdTargetB=850,1023 --for wheels to the back
			    local_cmd("car_steer_200","car_left")
                car_tmr_turn_right:interval(500)
                tmr.start(car_tmr_turn_right)
			end
		end
	end
    -- side infra follow
	function car_wall_follow_infra()
        tmr.stop(car_tmr_speedup)
        tmr.stop(car_tmr_turn_right)
        spdFactor=0.99      
		spdTargetA,spdTargetB=1023,1023
		if gpio.read(m.car_infra)==0 then
            spdFactor=0.95
            local_cmd("car_steer_200","car_steer_485")
            tmr.start(car_tmr_speedup)	
        elseif m.car_dist_hit==false then
            local_cmd("car_steer_200","car_steer_800")  --for wheels to the back
            car_tmr_turn_right:interval(300)
            tmr.start(car_tmr_turn_right)
		end	
	end
    -- side infra turn left 
    function car_wall_turn_infra()
        tmr.stop(car_tmr_speedup)
        tmr.stop(car_tmr_turn_right)
        spdFactor=0.99      
		spdTargetA,spdTargetB=1023,1023
		if gpio.read(m.car_infra)==0 then
            tmr.start(car_tmr_wall_turn_infra)	
        else
            tmr.stop(car_tmr_wall_turn_infra)
		end	
	end
    -- side infra follow line 
    function car_wall_line_infra()
        tmr.stop(car_tmr_speedup)
        tmr.stop(car_tmr_turn_right)
        --spdFactor=1      
		spdTargetA,spdTargetB=1023,1023
		if gpio.read(m.car_infra)==0 then
            tmr.stop(car_tmr_wall_line_infra)
            local_cmd("car_steer_200","car_steer_400")
        else
            tmr.start(car_tmr_wall_line_infra)
            local_cmd("car_steer_200","car_steer_700")   
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
    --turn right
    car_tmr_turn_right=tmr.create()    
	tmr.register(car_tmr_turn_right, 200, tmr.ALARM_SEMI, function () 
        spdFactor=0.99
        local_cmd("car_steer_900","car_steer_1000")
    end)
    -- speed up tmr
    car_tmr_speedup=tmr.create()
	tmr.register(car_tmr_speedup, 1000, tmr.ALARM_SEMI, function () 	
        spdFactor=1
        gpio.trig(m.car_infra,  'both', car_wall_line_infra)
    end)
      -- after left turn
    car_tmr_after_left=tmr.create()
	tmr.register(car_tmr_after_left, 1500, tmr.ALARM_SEMI, function ()
            spdTargetA,spdTargetB=1023,1023
            local_cmd("car_steer_200","car_steer_850")  
            --car_tmr_turn_right:interval(200)
            --tmr.start(car_tmr_turn_right)
    end)
    --
    car_tmr_wall_line_infra=tmr.create()
	tmr.register(car_tmr_wall_line_infra,1000, tmr.ALARM_SEMI, function ()
            spdTargetA,spdTargetB=1023,1023
            gpio.trig(m.car_infra,  'both', car_wall_follow_infra)
            spdTargetA,spdTargetB=1023,1023
            local_cmd("car_steer_200","car_steer_1000")
    end)
    --
    car_tmr_wall_turn_infra=tmr.create()
	tmr.register(car_tmr_wall_turn_infra,50, tmr.ALARM_SEMI, function ()
            tmr.stop(car_tmr_after_left)
            tmr.stop(car_tmr_speedup)
            gpio.trig(m.car_infra,  'both', car_wall_follow_infra)
            spdTargetA,spdTargetB=1023,1023
            local_cmd("car_steer_200","car_steer_435")
    end)
    -- distance bumper 
    car_tmr_dist_bumper=tmr.create()
	    tmr.register(car_tmr_dist_bumper,30, tmr.ALARM_AUTO, function () 	
        if distance <=2.6 and distance >=0.5  and m.car_dist_hit==false then
            tmr.stop(car_tmr_speedup)
            gpio.trig(m.car_infra,  'both', car_wall_turn_infra)
            m.car_dist_hit=true
            tmr.stop(car_tmr_turn_right)
            spdTargetA,spdTargetB=850,1023 --for wheels to the back
            tmr.start(car_tmr_after_left)
			local_cmd("car_steer_200","car_left")
            spdFactor=0.99
        elseif distance >=3 and m.car_dist_hit==true then
            m.car_dist_hit=false
        elseif distance <=10 then
             spdFactor=0.9
        end
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