
local function bcdToDec(val)
  return((((val/16) - ((val/16)%1)) *10) + (val%16))
end
local id=0
i2c.setup(id, ds3231_sda, ds3231_scl, i2c.SLOW)

--get time from DS3231
local function getime()
  i2c.start(0)
  i2c.address(0, 0x68, i2c.TRANSMITTER)
  i2c.write(id, 0x00)
  i2c.stop(id)
  i2c.start(id)
  i2c.address(0, 0x68, i2c.RECEIVER)
  local c=i2c.read(id, 7)
  i2c.stop(0)
  return bcdToDec(tonumber(string.byte(c, 1))),
  bcdToDec(tonumber(string.byte(c, 2))),
  bcdToDec(tonumber(string.byte(c, 3))),
  bcdToDec(tonumber(string.byte(c, 4))),
  bcdToDec(tonumber(string.byte(c, 5))),
  bcdToDec(tonumber(string.byte(c, 6))),
  bcdToDec(tonumber(string.byte(c, 7)))
end

time_second, time_minute, time_hour, time_day, time_date, time_month, time_year = getime();
