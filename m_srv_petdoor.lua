hc_server_responce=("No command "..pl.." found\n-options are petdoor_front_[open|close|toggle],petdoor_side_[open|close|toggle]")

if  string.find(pl,'petdoor_side_')  then
	action=string.sub(pl, 14,19)   
	side_door(action)
	hc_server_responce=("petdoor_side_door="..m.petdoor_side_door_state)
elseif string.find(pl,'petdoor_front_')  then
	action=string.sub(pl, 15,20)
	front_door(action)
	hc_server_responce=("petdoor_front_door="..m.petdoor_front_door_state)
elseif string.find(pl,'petdoor_button_')  then
	action=string.sub(pl, 16,22)
	button(action)
	hc_server_responce=("petdoor_button="..m.petdoor_button_state)
	
end
if  m.petdoor=="enabled" then
	m.petdoor="started"
	--
	pwm.setup(m.petdoor_side_door, 100, m.petdoor_side_door_lock_open)
	pwm.setup(m.petdoor_side_door_lock, 100, m.petdoor_side_door_open)
	pwm.setup(m.petdoor_front_door, 100, m.petdoor_front_door_open)
	--
	side_door_open_tmr=tmr.create()
	side_door_close_tmr=tmr.create()
	side_door_lock_open_tmr=tmr.create()
	side_door_lock_close_tmr=tmr.create()
	front_door_move_tmr=tmr.create()
	front_door_close_tmr=tmr.create()
	--
	gpio.mode(m.petdoor_button, gpio.INT, gpio.PULLUP)  --button	
	gpio.mode(m.petdoor_side_door_rid, gpio.INPUT, gpio.PULLUP) --side rid
	gpio.mode(m.petdoor_front_door_rid, gpio.INPUT, gpio.PULLUP) --front rid
--side door
	side_door_open_tmr:register(m.petdoor_side_door_speed, tmr.ALARM_AUTO, function (t) 
	        m.petdoor_side_door_position=m.petdoor_side_door_position-1
			pwm.setduty(m.petdoor_side_door,m.petdoor_side_door_position)
			if m.petdoor_side_door_position<=m.petdoor_side_door_open then
					if retry_s >= 100 then
						side_door_open_tmr:stop()
						pwm.stop(m.petdoor_side_door)
						m.petdoor_side_door_state="open"
						return
					end
					retry_s=retry_s+1
					m.petdoor_side_door_position=m.petdoor_side_door_open
			end
	end)		
	side_door_close_tmr:register(m.petdoor_side_door_speed, tmr.ALARM_AUTO, function (t) 
	        m.petdoor_side_door_position=m.petdoor_side_door_position+1
			pwm.setduty(m.petdoor_side_door,m.petdoor_side_door_position)
			if m.petdoor_side_door_position>=m.petdoor_side_door_closed then
		--		pwm.setduty(m.petdoor_side_door,m.petdoor_side_door_closed)
				if gpio.read(m.petdoor_side_door_rid) == 0 then
					side_door_close_tmr:stop()
					side_door_lock_close_tmr:start()	
				else
					if retry_s >= 5 then
						side_door_close_tmr:stop()
						pwm.stop(m.petdoor_side_door)
						retry_s=0
						side_door("open")
						return
					end
					retry_s=retry_s+1
					m.petdoor_side_door_position=m.petdoor_side_door_position-10
				end
				
			end
	end)	
--side door lock	
	side_door_lock_open_tmr:register(m.petdoor_side_door_lock_speed, tmr.ALARM_AUTO, function (t) 
	        m.petdoor_side_door_lock_position=m.petdoor_side_door_lock_position-1
			pwm.setduty(m.petdoor_side_door_lock,m.petdoor_side_door_lock_position)
			if m.petdoor_side_door_lock_position<=m.petdoor_side_door_lock_open then
				side_door_lock_open_tmr:stop()
				side_door_open_tmr:start()
				pwm.stop(m.petdoor_side_door_lock)
			end
	end)
	side_door_lock_close_tmr:register(m.petdoor_side_door_lock_speed, tmr.ALARM_AUTO, function (t) 
	        m.petdoor_side_door_lock_position=m.petdoor_side_door_lock_position+1
			pwm.setduty(m.petdoor_side_door_lock,m.petdoor_side_door_lock_position)
			if m.petdoor_side_door_lock_position>=m.petdoor_side_door_lock_closed then
				side_door_lock_close_tmr:stop()
				pwm.stop(m.petdoor_side_door_lock)
				pwm.stop(m.petdoor_side_door)
				m.petdoor_side_door_state="closed"
			end
	end)
--front door
	front_door_move_tmr:register(m.petdoor_front_door_speed, tmr.ALARM_AUTO, function (t) 
	        pwm.start(m.petdoor_front_door)
			if gpio.read(m.petdoor_front_door_rid) == 0 then
				retry_f=retry_f+1
				if retry_f>=10 then
					if m.petdoor_front_door_state=="opening" then
						m.petdoor_front_door_state="open"
					elseif m.petdoor_front_door_state=="closing" then
						m.petdoor_front_door_state="closed"
					end
					front_door_move_tmr:stop()
					pwm.stop(m.petdoor_front_door)
					wifi.sleeptype(wifi.LIGHT_SLEEP) --wifi.NONE_SLEEP,
				end
			else
				retry_f=7
			end
	end)		
--
	function side_door(action)
	retry_s=0
	side_door_open_tmr:stop()
	side_door_close_tmr:stop()
	side_door_lock_open_tmr:stop()
	side_door_lock_close_tmr:stop()
		if action=="open"  then
			if  m.petdoor_side_door_lock_position ~= m.petdoor_side_door_lock_open  then
				pwm.start(m.petdoor_side_door)
				side_door_lock_open_tmr:start()	
			else
				side_door_open_tmr:start()	
			end
		elseif action=="close" then
			if m.petdoor_side_door_lock_position == m.petdoor_side_door_lock_open  then
				side_door_close_tmr:start()	
			elseif m.petdoor_side_door_lock_position ~= m.petdoor_side_door_lock_closed then
				side_door_lock_close_tmr:start()	
			end
		elseif action=="toggle" then
			if m.petdoor_side_door_state~="open" and m.petdoor_side_door_state~="opening"   then
					m.petdoor_side_door_state="opening"
					side_door("open")
			else
					m.petdoor_side_door_state="closing"
					side_door("close")
			end
		end
	end
--	
	function front_door(action)
	retry_f=0
	front_door_move_tmr:stop()
	wifi.sleeptype(wifi.NONE_SLEEP) --wifi.NONE_SLEEP,
		if action=="open"  and  m.petdoor_front_door_state~="open" then
				m.petdoor_front_door_state="opening"
				pwm.setduty(m.petdoor_front_door,m.petdoor_front_door_open)
				front_door_move_tmr:start()	
		elseif action=="close" and  m.petdoor_front_door_state~="closed" then
				m.petdoor_front_door_state="closing"
				pwm.setduty(m.petdoor_front_door,m.petdoor_front_door_closed)
				front_door_move_tmr:start()	
		elseif action=="toggle" then
				if m.petdoor_front_door_state~="open" and m.petdoor_front_door_state~="opening" then
					front_door("open")
				else
				--if m.petdoor_front_door_state~="closed" and m.petdoor_front_door_state~="closing" then
					front_door("close")
				end
		end
	end
--	
	function button(action)
			if action=="disable" then
				m.petdoor_button_state="disabled"
				return
			elseif action=="enable" then
				m.petdoor_button_state="enabled"
				return
			elseif m.petdoor_button_state=="enabled" then
				local delay = 100000 
				local now = tmr.now()
				local delta = now - m.petdoor_button_lastpress
				if delta < 0 then delta = delta + 2147483647 end
				if delta < delay then  return end
				if gpio.read(m.petdoor_button) == 0 then
					front_door("toggle")
					m.petdoor_button_lastpress= tmr.now()
				end
			end
	end
--
	gpio.mode(m.petdoor_button, gpio.INT, gpio.PULLUP)
	gpio.trig(m.petdoor_button, 'down', button)
--
end	
--dofile("m_hc_server_petdoor.lua")
--node.compile("m_hc_server_petdoor.lua")
--print(node.heap())