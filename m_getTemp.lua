ow.setup(ow_pin)
local function bxor(a,b)
   local r = 0
   for i = 0, 31 do
      if ( a % 2 + b % 2 == 1 ) then
         r = r + 2^i
      end
      a = a / 2
      b = b / 2
   end
   print("mem inside module getTemp bxor function:"..node.heap())   
   return r
end

function getTemp()
tmr.wdclr()     
ow.reset(ow_pin)
ow.skip(ow_pin)
ow.write(ow_pin,0x44,1)
tmr.delay(800000)
ow.reset(ow_pin)
ow.skip(ow_pin)
ow.write(ow_pin,0xBE,1)

local data = nill
local data = string.char(ow.read(ow_pin))
local data = data .. string.char(ow.read(ow_pin))
local t=(data:byte(1) + data:byte(2)*256)

if (t > 32768) then
local t = (bxor(t, 0xffff)) + 1
local t = (-1)*t
end

getTemp_r  = t*625 /1000
ow.setup=nill
print("mem inside module getTemp:"..node.heap())   
bxor=nill
local t=nill
local data=nill
end
--dofile("m_getTemp.lua")
--node.compile("m_getTemp.lua")
--print(node.heap())
