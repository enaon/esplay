hc_server_responce=("No command "..pl.." found. options: stepper_1_left_steps")	

if  (string.find(pl,'stepper_left_') and string.sub(pl, 14,16))  then
	stepsNo=tonumber(string.sub(pl, 14,16))
   	hc_server_responce=("stepper_"..stepsNo.."_left")
	moveStep(0,stepsNo)	
elseif  (string.find(pl,'stepper_right_') and string.sub(pl, 15,17)) then
	stepsNo=tonumber(string.sub(pl, 15,17))
   	hc_server_responce=("stepper_"..stepsNo.."_right")
	moveStep(1,stepsNo)
end



if  m.stepper=="enabled" then
	m.stepper="started"
lookup = {B01000, 
          B01100, 
          B00100, 
          B00110, 
          B00010, 
          B00011, 
          B00001, 
          B01001}
-- INITIAL 74HC4051 OUTPUT PIN --------
gpio.mode(motorINT1, gpio.OUTPUT)
gpio.mode(motorINT2, gpio.OUTPUT)
gpio.mode(motorINT3, gpio.OUTPUT)
gpio.mode(motorINT4, gpio.OUTPUT)
function anticlockwise()
  for i = 0, 7 do
    setOutput(i);
    tmr.delay(motorSpeed);
  end
    gpio.write(motorINT1, gpio.LOW)
    gpio.write(motorINT2, gpio.LOW)
    gpio.write(motorINT3, gpio.LOW)
    gpio.write(motorINT4, gpio.LOW)
end

function clockwise()
  for i = 7, 0, -1 do
    setOutput(i);
    tmr.delay(motorSpeed);
  end
    gpio.write(motorINT1, gpio.LOW)
    gpio.write(motorINT2, gpio.LOW)
    gpio.write(motorINT3, gpio.LOW)
    gpio.write(motorINT4, gpio.LOW)
end


-- 74HC4051 - set Address -------------  
function setOutput(addressX)
    gpio.write(motorINT1, gpio.LOW)
    gpio.write(motorINT2, gpio.LOW)
    gpio.write(motorINT3, gpio.LOW)
    gpio.write(motorINT4, gpio.LOW)

    if addressX == 0 or addressX == 1 or 
        addressX == 7 then
        gpio.write(motorINT1, gpio.HIGH)
    end

    if (addressX == 2 or addressX == 3 or 
        addressX == 1) then
        gpio.write(motorINT2, gpio.HIGH)
    end

    if (addressX == 4 or addressX == 3 or 
        addressX == 5) then
        gpio.write(motorINT3, gpio.HIGH)
    end

    if (addressX == 6 or 
        addressX == 5 or addressX == 7) then
        gpio.write(motorINT4, gpio.HIGH)
    end


end

function moveStep(direction, nofMove)
    if(direction == 0 ) then
        print("Move : Clockwise - Steps " .. nofMove .. " [512 / Cycle]")
    else
        print("Move : Anti-Clockwise - Steps " .. nofMove .. " [512 / Cycle]")
    end
    for i = 0, nofMove, 1 do
        if(direction == 0 ) then
            clockwise();
        else
            anticlockwise();
        end    
    end
end
end
--moveStep(0, 256)
--moveStep(1, 256)
--node.compile("m_stepper.lua")