hc_server_responce=("No command "..pl.." found\nOptions dist_[get]_[cont]_[stop]")	
if (pl=="dist_get") then --stop
 measure()
hc_server_responce=("distance:"..distance);
elseif (pl=="dist_get_cont") then --stop
CONTINUOUS = true
hc_server_responce=("continuous enabled");
elseif (pl=="dist_get_cont_stop") then --stop
CONTINUOUS = false
hc_server_responce=("continuous disabled");
end
if m.hr04=="enabled" then
m.hr04="started"
READING_INTERVAL = math.ceil(((max_dist *2/ 340*1000) + TRIG_INTERVAL)*1.2)
-- initialize global variables
time_start = 0
time_stop = 0
distance = 0
readings = {}
-- start a measure cycle
function measure()
	readings = {}
	tmr.start(0)
end
-- called when measure is done
function done_measuring()
--	print("Distance: "..string.format("%.3f", distance).." Readings: "..#readings)
	distance=distance*100
--	print(distance)
	if distance >100 then
	remote_cmd("192.168.51.1","car_frwd")
	remote_cmd("192.168.51.1","car_speed_99")
	elseif distance <=55 then
	remote_cmd("192.168.51.1","car_left")
	elseif distance <=90 then
	remote_cmd("192.168.51.1","car_speed_85")
	end	
	if CONTINUOUS then
		node.task.post(measure)
	end
end
-- distance calculation, called by the echo_callback function on falling edge.
function calculate()
	-- echo time (or high level time) in seconds
	local echo_time = (time_stop - time_start) / 1000000
	-- got a valid reading
	if echo_time > 0 then
		-- distance = echo time (or high level time) in seconds* velocity of sound (340M/S) / 2
		local distance = echo_time *340 / 2
		table.insert(readings, distance)
	end
	-- got all readings
	if #readings >= AVG_READINGS then
		tmr.stop(0)
		-- calculate the average of the readings
		distance = 0
		for k,v in pairs(readings) do
			distance = distance + v
		end
		distance = distance / #readings
		node.task.post(done_measuring)
	end
end
-- echo callback function called on both rising and falling edges
function echo_callback(level)
	if level == 1 then
		time_start = tmr.now()
	else
		time_stop = tmr.now()
		calculate()
	end
end
-- send trigger signal
function trigger()
	gpio.write(TRIG_PIN, gpio.HIGH)
	tmr.delay(TRIG_INTERVAL)
	gpio.write(TRIG_PIN, gpio.LOW)
end
-- configure pins
gpio.mode(TRIG_PIN, gpio.OUTPUT)
gpio.mode(ECHO_PIN, gpio.INT)
-- trigger timer
tmr.register(0, READING_INTERVAL, tmr.ALARM_AUTO, trigger)
-- set callback function to be called both on rising and falling edges
gpio.trig(ECHO_PIN, "both", echo_callback)
end
end