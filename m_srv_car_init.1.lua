if m.car=="enabled" then
	--m.car_wheel_lock=1 
    --m.car_wheel_count_state=0
	m.car="started"
    m.car_bumper_lastpress=0
	car_compass_tmr=tmr.create()
	car_compass1_tmr=tmr.create()
    car_tmr_1=tmr.create()
		tmr.register(car_tmr_1, 1500, tmr.ALARM_SEMI, function () 	
        gpio.trig(m.car_infra,  'both', car_wall_follow_infra)
        gpio.trig(m.car_bumper,  'both'  , car_wall_follow_bumper)
    end)
     
    
    function car_smooth_right()
     local_cmd("car_steer_900","car_steer_700")
     tmr.start(car_tmr_turn)
    end

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
     car_tmr_speedup=tmr.create()
		tmr.register(car_tmr_speedup, 500, tmr.ALARM_SEMI, function () 	
        spdFactor=1
    end)
    car_tmr_dist_bumper=tmr.create()
		tmr.register(car_tmr_dist_bumper,5, tmr.ALARM_AUTO, function () 	
        if m.dist_state and m.dist_state=="on" and distance <=4 and distance >=1 then
            spdTargetA,spdTargetB=900,1023 --for wheels to the back
			local_cmd("car_steer_200","car_left")
            tmr.stop(car_tmr_dist_bumper)

        end
    end)
    --tmr.start(car_tmr_dist_bumper)
	--
--

    gpio.mode(m.car_bumper,gpio.OUTPUT)
	gpio.mode(m.car_bumper, gpio.INT, gpio.PULLUP)
	gpio.mode(m.car_infra, gpio.INT, gpio.PULLUP)
	--gpio.mode(m.car_wheel, gpio.INT, gpio.PULLUP)

-- dem0
	function car_demo(action)
    if action=="start" then
        local_cmd("car_steer_200","car_frwd")
        car_tmr_demo_move=tmr.create()
		    tmr.register(car_tmr_demo_move, 20, tmr.ALARM_AUTO, function () 	
            if m.car_wheel_count_state>= 150 then
                tmr.stop(car_tmr_demo_move)
                m.car_wheel_count_state=0
                local_cmd("car_steer_200","car_steer_1023")
                tmr.start(car_tmr_demo_turn)
            end
        end)
        --car_tmr_demo_turn=tmr.create()
		    --tmr.register(car_tmr_demo_turn, 20, tmr.ALARM_AUTO, function () 	
            --if m.car_wheel_count_state>= 91 then
            --    tmr.stop(car_tmr_demo_turn)
            --    m.car_wheel_count_state=0
            --   local_cmd("car_steer_200","car_stop")
            --    local_cmd("car_steer_200","car_frwd")
             --   tmr.start(car_tmr_demo_move)
            --end
        --end)
         --tmr.start(car_tmr_demo_move)

    else 
        tmr.stop(car_tmr_demo_turn)
        tmr.stop(car_tmr_demo_move)
        local_cmd("car_steer_200","car_stop")
    end
	end

-- wheel count
	--function car_wheel_count(level)
    --    m.car_wheel_count_state=m.car_wheel_count_state+1
	--end
 	--gpio.trig(m.car_wheel,  'down' , car_wheel_count)
-- wall follow
	function car_wall_follow(action)
		if action=="start" then	
			gpio.trig(m.car_bumper,  'both' , car_wall_follow_bumper)

		elseif action=="stop" then	
			gpio.trig(m.car_bumper)
			gpio.trig(m.car_infra)
		end
	end
	--bumper 
	function car_wall_follow_bumper(level)
        spdTargetA,spdTargetB=1023,1023
        tmr.stop(car_tmr_turn)
        tmr.stop(car_tmr_speedup)
        spdFactor=1
            tmr.start(car_tmr_dist_bumper)

		if gpio.read(m.car_bumper)==0 then
            gpio.trig(m.car_infra)
            spdFactor=1
            spdTargetA,spdTargetB=900,1023 --for wheels to the back
			local_cmd("car_steer_200","car_left")
		else 			
            gpio.trig(m.car_infra,  'both', car_wall_follow_infra)
			if gpio.read(m.car_infra)==0 then
                --spdFactor=0.8 --for wheels to the back
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
                --spdFactor=0.9
                spdTargetA,spdTargetB=800,1023 --for wheels to the back
    			local_cmd("car_steer_200","car_left")
			end
		end
	end
    function car_wall_follow_bumper_1(level)

        spdTargetA,spdTargetB=800,800
		if gpio.read(m.car_bumper)==0 then
			gpio.trig(m.car_infra)
			local_cmd("car_steer_200","car_left")
        end 
    end

-- infra side
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
            --local_cmd("car_steer_200","car_steer_800")
            --spdFactor=0.9 --for wheels to the back
            local_cmd("car_steer_200","car_steer_750")  --for wheels to the back
            --car_tmr_turn:interval(200) 
            --car_tmr_turn:interval(20) --for wheels to the back
            tmr.start(car_tmr_turn)
		end	
	end
		
	
--GPIO define for wheels
	function initGPIO()
		gpio.mode(m.car_pwm_1,gpio.OUTPUT);gpio.write(m.car_pwm_1,gpio.LOW);
		gpio.mode(m.car_pwm_2,gpio.OUTPUT);gpio.write(m.car_pwm_2,gpio.LOW);
		gpio.mode(m.car_dir_1,gpio.OUTPUT);gpio.write(m.car_dir_1,gpio.HIGH);
		gpio.mode(m.car_dir_2,gpio.OUTPUT);gpio.write(m.car_dir_2,gpio.HIGH);     
		pwm.setup(m.car_pwm_1,1000,1023);--PWM 1KHz, Duty 1023
		pwm.start(m.car_pwm_1);pwm.setduty(m.car_pwm_1,0);
		pwm.setup(m.car_pwm_2,1000,1023);
		pwm.start(m.car_pwm_2);pwm.setduty(m.car_pwm_2,0);
	end

	print("Start car Control");
		initGPIO();
		spdTargetA=1023;--target Speed
		spdCurrentA=0;--current speed
		spdTargetB=1023;--target Speed
		spdCurrentB=0;--current speed
		stopFlag=true;
	--speed control procedure
	car_tmr=tmr.create()
			tmr.register(car_tmr, 50, tmr.ALARM_AUTO, function () 	
		if stopFlag==false then
			spdCurrentA=spdTargetA*spdFactor;
			spdCurrentB=spdTargetB*spdFactor;
			pwm.setduty(m.car_pwm_1,spdCurrentA);
			pwm.setduty(m.car_pwm_2,spdCurrentB);
		else
			pwm.setduty(m.car_pwm_1,0);
			pwm.setduty(m.car_pwm_2,0);
		end
	end)
	tmr.start(car_tmr)
end

--dofile("m_srv_car.lua")
--node.compile("m_srv_car_init.lua")
--print(node.heap())