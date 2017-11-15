
-- init functions once
if  m.sunbox=="enabled" then
	m.sunbox="started"
            
    m.sunbox_door_pos_lastpress=0
--
    gpio.mode(m.sunbox_door_lock_rid, gpio.INPUT, gpio.PULLUP) 
    gpio.mode(m.sunbox_door_pos_rid, gpio.INPUT, gpio.PULLUP)
    -- enable antivandal trigger
    gpio.mode(m.sunbox_antivandal_pin, gpio.INT, gpio.PULLUP) 
--
	sunbox_door_lock_tmr=tmr.create()
    sunbox_oled_info_tmr=tmr.create()
-- timer for oled info message handling 
    sunbox_oled_loop=0
    sunbox_oled_info_tmr:register(5000, tmr.ALARM_AUTO, function (t)
        sunbox_oled_loop=sunbox_oled_loop+1
        if sunbox_oled_loop==1 then
             m.oled_largeen=m.sunbox_mode_state  m.oled_line2en='~  swim  safe  ~' 
        elseif sunbox_oled_loop==2 then
             m.oled_largeen=m.sunbox_mode_state  m.oled_line2en='~  wear a hat  ~'
        elseif sunbox_oled_loop==3 and m.sunbox_key_message~="" then 
            m.oled_largeen=m.sunbox_mode_state  m.oled_line2en=m.sunbox_key_message
        else m.oled_largeen="SunBox"  m.oled_line2en='safe keeping'
             sunbox_oled_loop=0    
        end
        oled_refresh()
    end)
    sunbox_oled_info_tmr:start()
--  antivandal function
   	function sunbox_antivandal()
        sunbox_oled_info_tmr:stop()
        sunbox_oled_info_tmr:start()
        m.oled_largeen="Alarm"
        m.oled_line2en="Vandalism"
        oled_refresh()
        buzzer(100,500,4)
    end
-- function used for door locking-unlocking.
	function sunbox_door(action)
    buzzer_hold=1
	retry_f=0
	sunbox_door_lock_tmr:stop()
	if action=="unlock"  then
        gpio.write(m.sunbox_door_lock_rid,1)    --for gpio0 with no pullup 
        gpio.trig(m.sunbox_door_pos_rid, 'down', sunbox_door_pos)  	   
        pwm.setup(m.sunbox_door_servo, 50, m.sunbox_door_unlocked)
		pwm.setduty(m.sunbox_door_servo,m.sunbox_door_unlocked)
        if m.sunbox_door_state~="locked" then
--            m.oled_largeen="Open" m.oled_line2en="~   welcome   ~"                  
        --else 
        m.oled_largeen="Failed" m.oled_line2en="try again" 
            oled_refresh()
        end
        sunbox_door_lock_tmr:register(300, tmr.ALARM_SINGLE, function (t) 
            pwm.stop(m.sunbox_door_servo)
            buzzer_hold=nil  
            sunbox_door_lock_tmr:stop() 
            buzzer(70,100,0)
        end)
        gpio.trig(m.sunbox_antivandal_pin)
        sunbox_door_lock_tmr:start()
        m.sunbox_door_state="unlocked"
        hc_server_responce="sunbox_door_unlocked"
	elseif action=="lock" and m.sunbox_mode_state~="Upkeep" and m.sunbox_key_present~="yes" then
        sunbox_oled_info_tmr:stop()
        sunbox_oled_info_tmr:start()
        pwm.setup(m.sunbox_door_servo, 50, m.sunbox_door_locked)
		pwm.setduty(m.sunbox_door_servo,m.sunbox_door_locked)
        sunbox_door_lock_tmr:register(10, tmr.ALARM_AUTO, function (t) 
            retry_f=retry_f+1
            
            if gpio.read(m.sunbox_door_pos_rid)== 1  then --if door rid is not zero, cancel lock attempt.
                pwm.stop(m.sunbox_door_servo)
                buzzer_hold=nil  
                sunbox_door("unlock")
                return
            elseif gpio.read(m.sunbox_door_lock_rid)== 0 then --if lock rid is zero then we have done it. 
                if retry_f==60 then --b.then finish locking and report success.
                    gpio.trig(m.sunbox_door_pos_rid,'up', sunbox_door_pos)     
                    m.sunbox_door_state="locked"    
                    sunbox_door_lock_tmr:stop()
                    pwm.stop(m.sunbox_door_servo)
                    buzzer_hold=nil  
                    m.oled_largeen="Locked"  m.oled_line2en='Safeguarding' oled_refresh()
                    gpio.trig(m.sunbox_antivandal_pin, 'down', sunbox_antivandal)
                    buzzer(100,50,1) 
                elseif retry_f<=50 then --a.give some more time for the servo to finish
                    retry_f=51                
                    sunbox_door_lock_tmr:interval(50)
                end 
            elseif retry_f>=70 then --the lock rid was not activated, cancel lock atempt.
                sunbox_door_lock_tmr:stop()  
                pwm.stop(m.sunbox_door_servo)
                buzzer_hold=nil  
                --buzzer(50,100,4)  
                sunbox_door("unlock")
            end
        end)
        sunbox_door_lock_tmr:start()
        hc_server_responce=("sunbox_door_locked")
    elseif action=="state"  then
        hc_server_responce=("sunbox_door_"..m.sunbox_door_state)
	end
    
    end
--	function called by position rid trigger.
	function sunbox_door_pos(action)
    	--bounce filter
        local delay = 500000 
		local now = tmr.now()
		local delta = now - m.sunbox_door_pos_lastpress
		if delta < 0 then delta = delta + 2147483647 end
		if delta < delay then  return end
        sunbox_oled_info_tmr:stop()
        sunbox_oled_info_tmr:start()
        --main logic based on m.sunbox_mode_state
		if m.sunbox_door_state=="unlocked" and gpio.read(m.sunbox_door_pos_rid)==0 then
			if m.sunbox_mode_state=="Vacant" then 
                m.oled_largeen="Please"
                m.oled_line2en="Insert Key"
                buzzer(100,50,0)
            elseif m.sunbox_mode_state=="Booked" and m.sunbox_key_present=="yes" then
                m.oled_largeen="Eject"
                m.oled_line2en="Key to lock"
                --buzzer(100,50,0)
            else
                m.oled_largeen="Wait"
                m.oled_line2en="Locking"
                sunbox_door("lock")
            end
            m.sunbox_door_pos_lastpress= tmr.now()
            oled_refresh()
        elseif m.sunbox_door_state=="locked" then --send an alarm here
            --buzzer(50,100,9)
            sunbox_door("unlock") 
            m.sunbox_door_pos_lastpress= tmr.now()           
		end
    
	end
-- enable pos trigger    
    gpio.mode(m.sunbox_door_pos_rid, gpio.INT, gpio.PULLUP)
	gpio.trig(m.sunbox_door_pos_rid, 'down', sunbox_door_pos)
--
end	
--dofile("m_srv_sunbox_init.lua")
--node.compile("m_srv_sunbox_init.lua")
--print(node.heap())