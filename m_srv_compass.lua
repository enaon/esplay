id  = 0 -- always 0

--Define declination of location from where measurement going to be done.
--e.g. here we have added declination from location Pune city, India.
--we can get it from http://www.magnetic-declination.com 
pi = 3.14159265358979323846
Declination =4.46

function arcsin(value)
    local val = value
    local sum = value 
    if(value == nil) then
        return 0
    end
-- as per equation it needs infinite iterations to reach upto 100% accuracy
-- but due to technical limitations we are using
-- only 10000 iterations to acquire reliable accuracy
    for i = 1, 10000, 2 do
        val = (val*(value*value)*(i*i)) / ((i+1)*(i+2))
        sum = sum + val;
    end
    return sum
end

function arctan(value)
    if(value == nil) then
        return 0
    end
    local _value = value/math.sqrt((value*value)+1)
    return arcsin(_value)
end

function atan2(y, x)
    if(x == nil or y == nil) then
        return 0
    end

    if(x > 0) then
        return arctan(y/x)
    end
    if(x < 0 and 0 <= y) then
        return arctan(y/x) + pi
    end
    if(x < 0 and y < 0) then
        return arctan(y/x) - pi
    end
    if(x == 0 and y > 0) then
        return pi/2
    end
    if(x == 0 and y < 0) then
        return -pi/2
    end
    if(x == 0 and y == 0) then
        return 0
    end
    return 0
end

hmc5883l.init(m.compass_sda, m.compass_scl)       --initialize hmc5883l
compass_tmr=tmr.create()
compass_tmr:register(250, tmr.ALARM_AUTO, function(t)  
    local z,y,x = hmc5883l.read()
    local Heading = atan2(y, x) + Declination

    if (Heading>2*pi) then    --Due to declination check for >360 degree 
        Heading = Heading - 2*pi
    end
    if (Heading<0) then       --Check for sign
        Heading = Heading + 2*pi
    end

    Heading = Heading*180/pi  --convert radian to angle
    print(string.format("Heading angle : %d", Heading))
    m.compass_state=tonumber(string.format("%d", Heading))
end)
compass_tmr:start()

--dofile("m_srv_compass.lua")
--node.compile("m_srv_compass.lua")
--print(node.heap())