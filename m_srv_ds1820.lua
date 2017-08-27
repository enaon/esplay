hc_server_responce=("No command "..pl.." found\nOptions ds1820_[get]_[print]")	
if (pl=="ds1820_get") then --stop
 getTemp()
hc_server_responce=("temp got, enter ds1820_print for results");
elseif (pl=="ds1820_print") then --stop
hc_server_responce=ds1820_temp
end
if m.ds1820=="enabled" then
	m.ds1820="started"
	ow.setup(ds1820_pin)
	counter=0
	temps={}

	function bxor(a,b)
		local r = 0
		for i = 0, 31 do
			if ( a % 2 + b % 2 == 1 ) then
				r = r + 2^i
			end
			a = a / 2
			b = b / 2
		end
		return r
	end

	function getTemp()
		addr = ow.reset_search(ds1820_pin)
		repeat
		tmr.wdclr()
		if (addr ~= nil) then
			crc = ow.crc8(string.sub(addr,1,7))
			if (crc == addr:byte(8)) then
				if ((addr:byte(1) == 0x10) or (addr:byte(1) == 0x28)) then
					sensor = ""
					for j = 1,8 do sensor = sensor .. string.format("%02x", addr:byte(j)) end
					ow.reset(ds1820_pin)
					ow.select(ds1820_pin, addr)
					ow.write(ds1820_pin, 0x44, 1)
					tmr.delay(1000000)
					present = ow.reset(ds1820_pin)
					ow.select(ds1820_pin, addr)
					ow.write(ds1820_pin,0xBE, 1)
					data = nil
					data = string.char(ow.read(ds1820_pin))
					for i = 1, 8 do
						data = data .. string.char(ow.read(ds1820_pin))
					end
					crc = ow.crc8(string.sub(data,1,8))
					if (crc == data:byte(9)) then
						t = (data:byte(1) + data:byte(2)*256)
						if (t > 32768) then
							t = (bxor(t, 0xffff)) + 1
							t = (-1)*t
						end
						t = t*625
						if(addr:byte(1) == 0x10) then
							-- we have DS18S20, the measurement must change
							t = t*8;  -- compensating for the 9-bit resolution only
							t = t - 2500 + ((10000*(data:byte(8) - data:byte(7))) / data:byte(8))
						end
						temps[sensor] = t
						--print(sensor .. ": " .. t)
						--ds1820_temp=(sensor .. ": " .. t)
					end                   
				tmr.wdclr()
				end
			end
		end
		addr = ow.search(ds1820_pin)
		until(addr == nil)
		ds1820_temp=""
		for k, v in pairs( temps ) do
			ds1820_temp=(k.."-"..v.."\n"..ds1820_temp)
		end
	end
end
