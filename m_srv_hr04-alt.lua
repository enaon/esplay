--hc_server_responce=("No command "..pl.." found\nOptions are:\npir_[lights|alarm|disable|status]")	

--local measure = require "m_srv_hr04" measure(5,6,3,1,function(d) print(d) end)

local gpio, time_start, time_end, trigger, echo = gpio, 0, 0
local sample_count, timer_id

return function(trig_pin, echo_pin, sample_cnt, timer_id, report_cb)
    trigger, echo   = trig_pin or 5, echo_pin or 6
    sample_count, timer_id = (sample_cnt+1) or 4, timer_id or 1   

    local total, i, result = 0, 0, {}

    local function echo_cb(level)
      if level == 1 and result[i] == 0 then
        result[i] = -tmr.now()
        gpio.trig(echo, "down")
      elseif level == 0 and result[i] < 0 then
        result[i] = tmr.now() + result[i];
        gpio.trig(echo, "none")
      else
        gpio.trig(echo, "none") -- anything else turn off interrupts and restart at next sample
        print("DEBUG INT off")
      end
    end
    
    local function measure()
      if i > 0 then -- process last sample
        if result[i] < 0 then  
          result[i] = 0
          i = i - 1
          return -- skip a beat to allow the sonar to settle down
        else 
          total = total + result[i];
        end
        if i == sample_count then
          tmr.unregister(timer_id)
          for j = 1, sample_count do print(("Sample %u is %u"):format(j,result[j])) end
          total = total - result[1] -- substract sample one because it is usually off...
          return report_cb(total / (58*(sample_count-1)))
        end
      end

      gpio.mode(echo, gpio.INT)
      gpio.trig(echo, "up", echo_cb)
      gpio.write(trigger, gpio.HIGH); tmr.delay(20); gpio.write(trigger, gpio.LOW)
	i = i + 1
    end
    
    for j = 0, sample_count do result[j] = 0 end -- pre-allocate result array

    gpio.mode(trigger, gpio.OUTPUT)
    tmr.alarm(timer_id, 60, tmr.ALARM_AUTO, measure)
	
    measure()
  end
--dofile("m_srv_hr04.lua")
--node.compile("m_srv_pir.lua")
--print(node.heap())
