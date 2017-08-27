local id=0
local dev_addr = 0x68 
i2c.setup(id, ds3231_sda, ds3231_scl, i2c.SLOW)
local function decToBcd(val)
  if val == nil then return 0 end
  return((((val/10) - ((val/10)%1)) *16) + (val%10))
end
local function bcdToDec(val)
  return((((val/16) - ((val/16)%1)) *10) + (val%16))
end
local function getime()
  i2c.start(id)
  i2c.address(id, dev_addr , i2c.TRANSMITTER)
  i2c.write(id, 0x00)
  i2c.stop(id)
  i2c.start(id)
  i2c.address(id, dev_addr , i2c.RECEIVER)
  local c=i2c.read(id, 7)
  i2c.stop(id)
  return 
  bcdToDec(tonumber(string.byte(c, 1))),
  bcdToDec(tonumber(string.byte(c, 2))),
  bcdToDec(tonumber(string.byte(c, 3))),
  bcdToDec(tonumber(string.byte(c, 4))),
  bcdToDec(tonumber(string.byte(c, 5))),
  bcdToDec(tonumber(string.byte(c, 6))),
  bcdToDec(tonumber(string.byte(c, 7)))
end
local function setime(second, minute, hour, day, date, month, year)
  i2c.start(id)
  i2c.address(id, dev_addr , i2c.TRANSMITTER)
  i2c.write(id, 0x00)
  i2c.write(id, decToBcd(second))
  i2c.write(id, decToBcd(minute))
  i2c.write(id, decToBcd(hour))
  i2c.write(id, decToBcd(day))
  i2c.write(id, decToBcd(date))
  i2c.write(id, decToBcd(month))
  i2c.write(id, decToBcd(year))
  i2c.stop(id)
end

if m.node_time_set and string.match(m.node_time_set,'node_time_set_(%d+)-(%d+)-(%d+)-(%d+)-(%d+)-(%d+)-(%d+)') then
	setime(string.match(m.node_time_set,'node_time_set_(%d+)-(%d+)-(%d+)-(%d+)-(%d+)-(%d+)-(%d+)')) 
	m.node_time_set=nil
end

local time_second, time_minute, time_hour, time_day, time_date, time_month, time_year = getime();
m.node_time=(time_hour..":"..time_minute..":"..time_second)
m.node_date=(time_date.."/"..time_month.."/"..time_year)
